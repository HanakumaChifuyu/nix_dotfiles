"""Run sing-box on macOS with runtime secrets and reversible system DNS."""

import argparse
import fcntl
import ipaddress
import json
import os
from pathlib import Path
import signal
import socket
import subprocess
import sys
import tempfile
import time


TUN_DNS = ["172.19.0.2"]


def write_json(path, value):
    """Publish a complete mode-600 file, including after a previous crash."""
    path = Path(path)
    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as stream:
        temporary = Path(stream.name)
        try:
            json.dump(value, stream)
            stream.flush()
            os.fsync(stream.fileno())
            os.replace(temporary, path)
        finally:
            temporary.unlink(missing_ok=True)


class SystemDNS:
    def __init__(self, state_file, command=None):
        self.state_file = Path(state_file)
        self.command = command or self.networksetup

    @staticmethod
    def networksetup(*args):
        result = subprocess.run(
            ["/usr/sbin/networksetup", *args], capture_output=True, text=True,
            env={**os.environ, "LC_ALL": "C", "LANG": "C"}, timeout=10,
        )
        # networksetup sometimes reports errors on stdout with exit code zero.
        if result.returncode or "Error" in result.stdout:
            raise RuntimeError("networksetup failed: " + " ".join(args[:2]))
        return result.stdout.strip()

    def current(self, service):
        text = self.command("-getdnsservers", service)
        if text.startswith("There aren't any DNS Servers set"):
            return []  # Empty restores DHCP-provided DNS, not its current address.
        return text.splitlines()

    def apply(self):
        saved = json.loads(self.state_file.read_text()) if self.state_file.exists() else {}
        services = self.command("-listallnetworkservices").splitlines()[1:]
        for service in services:
            if not service or service.startswith("*") or service in saved:
                continue
            previous = self.current(service)
            if previous == TUN_DNS:
                raise RuntimeError(f"{service} already uses sing-box DNS without a saved original")
            saved[service] = previous
            # Save before mutation, so recovery works even if the process is killed.
            write_json(self.state_file, saved)
            self.command("-setdnsservers", service, *TUN_DNS)

    def restore(self):
        if not self.state_file.exists():
            return
        saved = json.loads(self.state_file.read_text())
        remaining = {}
        for service, previous in saved.items():
            try:
                # Preserve DNS changes made by the user or another application.
                if self.current(service) == TUN_DNS:
                    self.command("-setdnsservers", service, *(previous or ["Empty"]))
            except (RuntimeError, subprocess.TimeoutExpired):
                remaining[service] = previous
        if remaining:
            write_json(self.state_file, remaining)
            raise RuntimeError("Some DNS settings could not be restored; retry restore-dns")
        self.state_file.unlink()


def validate_tun_routes(config):
    for inbound in config["inbounds"]:
        if inbound["type"] != "tun":
            continue
        networks = [ipaddress.ip_network(value, strict=False) for value in inbound["address"]]
        excluded = [ipaddress.ip_network(value) for value in inbound.get("route_exclude_address", [])]
        for network in networks:
            if any(network.version == item.version and network.overlaps(item) for item in excluded):
                raise RuntimeError("TUN route exclusions overlap the TUN subnet; DNS/TCP would bypass utun")
        for address in TUN_DNS:
            if not any(ipaddress.ip_address(address) in network for network in networks):
                raise RuntimeError("The managed DNS address is outside the TUN subnet")


def render(args, directory, proxy_only=False):
    result = subprocess.run(
        [args.sops, "--decrypt", "--extract", '["sing_box"]["jp_osaka"]["hysteria2"]',
         "--output-type", "json", args.secrets],
        env={**os.environ, "SOPS_AGE_KEY_FILE": args.identity},
        capture_output=True, text=True, timeout=30,
    )
    if result.returncode:
        raise RuntimeError("SOPS could not decrypt the sing-box node; run check-mac-age.sh --require-secrets")
    node = json.loads(result.stdout)
    credentials = [node["server_ip"], node["passwd"], node["obfs"]["password"], node["tls"]["server_name"]]
    if not all(isinstance(value, str) and value.strip() for value in credentials):
        raise RuntimeError("The sing-box node has an empty or invalid credential field")
    config = json.loads(Path(args.template).read_text())
    validate_tun_routes(config)
    outbound = next(item for item in config["outbounds"] if item["tag"] == "proxy")
    outbound["server"], outbound["password"], outbound["obfs"]["password"], outbound["tls"]["server_name"] = credentials
    if proxy_only:
        config["inbounds"] = [item for item in config["inbounds"] if item["type"] == "mixed"]
        config["inbounds"][0]["listen_port"] = args.port
    path = Path(directory) / "config.json"
    write_json(path, config)
    result = subprocess.run([args.sing_box, "check", "-c", str(path)], capture_output=True, text=True)
    if result.returncode:
        # Validation can include config values; keep them out of console output.
        raise RuntimeError("sing-box rejected the generated configuration")
    return path


def wait_for_listener(process, port, stopping):
    for _ in range(100):
        if stopping():
            raise RuntimeError("Startup interrupted")
        if process.poll() is not None:
            raise RuntimeError("sing-box exited before its listener was ready")
        try:
            with socket.create_connection(("127.0.0.1", port), timeout=0.1):
                return
        except OSError:
            time.sleep(0.1)
    raise RuntimeError("Timed out waiting for the sing-box listener")


def stop_process(process):
    if process is None or process.poll() is not None:
        return
    process.terminate()
    try:
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait()


def check_port_available(port):
    # Do not mistake an existing proxy's listener for this process during startup.
    with socket.socket() as probe:
        # Match sing-box's listener: closed connections in TIME_WAIT must not
        # block a restart, while a live listening socket must still be rejected.
        probe.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            probe.bind(("127.0.0.1", port))
        except OSError as error:
            raise RuntimeError(f"Port {port} is occupied; stop the other proxy first") from error


def proxy_test(args):
    check_port_available(args.port)
    with tempfile.TemporaryDirectory(prefix="sing-box-proxy-test-") as directory:
        path = render(args, directory, proxy_only=True)
        with open(Path(directory) / "service.log", "w") as log:
            process = subprocess.Popen(
                [args.sing_box, "run", "-D", directory, "-c", str(path)], stdout=log, stderr=log,
            )
            try:
                wait_for_listener(process, args.port, lambda: False)
                for label, url in [
                    ("Hysteria2 proxy", "https://www.gstatic.com/generate_204"),
                    ("direct mirror", "https://mirrors.tuna.tsinghua.edu.cn/"),
                ]:
                    result = subprocess.run(
                        [args.curl, "--fail", "--silent", "--show-error", "--max-time", "30",
                         "--proxy", f"http://127.0.0.1:{args.port}", "--noproxy", "",
                         "--output", os.devnull, url], capture_output=True, text=True,
                    )
                    if result.returncode:
                        raise RuntimeError(f"{label} connectivity failed (curl exit {result.returncode})")
                    print(f"PASS: {label}", flush=True)
            except RuntimeError as error:
                log.flush()
                details = (Path(directory) / "service.log").read_text()[-3000:]
                node = next(item for item in json.loads(path.read_text())["outbounds"] if item["tag"] == "proxy")
                for value in [node["server"], node["password"], node["obfs"]["password"], node["tls"]["server_name"]]:
                    details = details.replace(value, "<redacted>")
                raise RuntimeError(f"{error}\n{details}") from error
            finally:
                stop_process(process)


def run_service(args):
    if os.geteuid() != 0:
        raise RuntimeError("TUN service and system DNS require sudo")
    state = Path(args.state_dir)
    state.mkdir(mode=0o700, parents=True, exist_ok=True)
    os.chmod(state, 0o700)
    with (state / "service.lock").open("a") as lock:
        try:
            fcntl.flock(lock.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as error:
            raise RuntimeError("sing-box-mac is already running; stop its launchd service first") from error
        run_locked(args, state)


def run_locked(args, state):
    dns = SystemDNS(state / "dns-state.json")
    # Restore after a previous crash before taking a fresh DNS snapshot.
    dns.restore()
    if args.command == "restore-dns":
        print("Saved DNS settings restored", flush=True)
        return
    check_port_available(7890)
    path = render(args, state)
    stopped = False

    def on_signal(_signum, _frame):
        nonlocal stopped
        stopped = True

    signal.signal(signal.SIGTERM, on_signal)
    signal.signal(signal.SIGINT, on_signal)
    process = None
    try:
        process = subprocess.Popen([args.sing_box, "run", "-D", str(state), "-c", str(path)])
        wait_for_listener(process, 7890, lambda: stopped)
        dns.apply()
        print("sing-box TUN ready; previous DNS saved", flush=True)
        while not stopped and process.poll() is None:
            # Include newly added/re-enabled network services after dock changes.
            for _ in range(10):
                if stopped or process.poll() is not None:
                    break
                time.sleep(1)
            if not stopped and process.poll() is None:
                dns.apply()
        if not stopped:
            raise RuntimeError("sing-box exited; launchd will restart the service")
    finally:
        try:
            dns.restore()
        finally:
            stop_process(process)
            path.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--template", required=True)
    parser.add_argument("--secrets", required=True)
    parser.add_argument("--identity", required=True)
    parser.add_argument("--sing-box", required=True)
    parser.add_argument("--sops", required=True)
    parser.add_argument("--curl", required=True)
    parser.add_argument("--state-dir", default="/var/lib/sing-box")
    parser.add_argument("--port", type=int, default=19890)
    parser.add_argument("command", choices=["check", "proxy-test", "run", "restore-dns"])
    args = parser.parse_args()
    os.umask(0o077)
    if args.command == "check":
        with tempfile.TemporaryDirectory(prefix="sing-box-check-") as directory:
            render(args, directory)
        print("PASS: runtime decryption and macOS sing-box configuration")
    elif args.command == "proxy-test":
        proxy_test(args)
    else:
        run_service(args)


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, KeyError, ValueError, OSError, subprocess.TimeoutExpired) as error:
        print(f"sing-box-mac: {error}", file=sys.stderr)
        sys.exit(1)
