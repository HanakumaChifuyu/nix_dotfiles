"""DNS rollback and runtime-secret regression tests; no root or network required."""

import importlib.util
import json
import socket
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location("mac_service", Path(__file__).with_name("mac-service.py"))
service = importlib.util.module_from_spec(spec)
spec.loader.exec_module(service)


class FakeNetworkSetup:
    def __init__(self):
        self.servers = {"Wi-Fi": [], "USB Ethernet": ["223.5.5.5", "1.1.1.1"]}
        self.fail_set = set()

    def __call__(self, command, name=None, *addresses):
        if command == "-listallnetworkservices":
            return "An asterisk denotes a disabled service.\n" + "\n".join(self.servers) + "\n*Disabled VPN"
        if command == "-getdnsservers":
            values = self.servers[name]
            return "\n".join(values) if values else f"There aren't any DNS Servers set on {name}."
        if command == "-setdnsservers":
            if name in self.fail_set:
                raise RuntimeError("Simulated networksetup failure")
            self.servers[name] = [] if addresses == ("Empty",) else list(addresses)
            return ""
        raise AssertionError(command)


class DNSRecoveryTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.path = Path(self.temporary.name) / "dns-state.json"
        self.network = FakeNetworkSetup()
        self.manager = service.SystemDNS(self.path, self.network)

    def test_restore_dhcp_and_static_dns(self):
        original = dict(self.network.servers)
        self.manager.apply()
        self.assertEqual(self.network.servers["Wi-Fi"], service.TUN_DNS)
        self.assertEqual(self.path.stat().st_mode & 0o777, 0o600)
        self.manager.restore()
        self.assertEqual(self.network.servers, original)
        self.assertFalse(self.path.exists())

    def test_restart_recovers_snapshot_after_crash(self):
        self.manager.apply()
        restarted = service.SystemDNS(self.path, self.network)
        restarted.restore()
        restarted.apply()
        self.assertEqual(json.loads(self.path.read_text())["Wi-Fi"], [])
        restarted.restore()
        self.assertEqual(self.network.servers["Wi-Fi"], [])

    def test_preserve_dns_edited_while_running(self):
        self.manager.apply()
        self.network.servers["Wi-Fi"] = ["9.9.9.9"]
        self.manager.restore()
        self.assertEqual(self.network.servers["Wi-Fi"], ["9.9.9.9"])

    def test_partial_setup_failure_is_recoverable(self):
        self.network.fail_set.add("USB Ethernet")
        with self.assertRaises(RuntimeError):
            self.manager.apply()
        self.assertEqual(json.loads(self.path.read_text())["Wi-Fi"], [])
        self.manager.restore()
        self.assertEqual(self.network.servers["Wi-Fi"], [])
        self.assertFalse(self.path.exists())

    def test_restore_failure_keeps_snapshot_for_retry(self):
        self.manager.apply()
        self.network.fail_set.add("Wi-Fi")
        with self.assertRaises(RuntimeError):
            self.manager.restore()
        self.assertEqual(json.loads(self.path.read_text()), {"Wi-Fi": []})
        self.network.fail_set.clear()
        self.manager.restore()
        self.assertEqual(self.network.servers["Wi-Fi"], [])

    def test_new_service_keeps_original_snapshot(self):
        self.manager.apply()
        self.network.servers["Dock Ethernet"] = ["8.8.8.8"]
        self.manager.apply()
        self.assertEqual(json.loads(self.path.read_text())["Wi-Fi"], [])
        self.manager.restore()
        self.assertEqual(self.network.servers["Dock Ethernet"], ["8.8.8.8"])

    def test_do_not_save_tun_dns_as_original_without_snapshot(self):
        self.network.servers["Wi-Fi"] = service.TUN_DNS[:]
        with self.assertRaises(RuntimeError):
            self.manager.apply()
        self.assertFalse(self.path.exists())

    def test_restore_command_cannot_change_dns_of_a_running_service(self):
        args = SimpleNamespace(state_dir=self.temporary.name, command="restore-dns")
        with (Path(self.temporary.name) / "service.lock").open("a") as lock:
            service.fcntl.flock(lock.fileno(), service.fcntl.LOCK_EX)
            with patch.object(service.os, "geteuid", return_value=0):
                with self.assertRaisesRegex(RuntimeError, "already running"):
                    service.run_service(args)


class RuntimeSecretsTests(unittest.TestCase):
    def test_only_runtime_file_receives_credentials(self):
        with tempfile.TemporaryDirectory() as directory:
            template = Path(directory) / "template.json"
            base = {
                "outbounds": [{"tag": "proxy", "obfs": {}, "tls": {}}],
                "inbounds": [{"type": "mixed", "listen_port": 7890},
                             {"type": "tun", "address": ["172.19.0.1/30"]}],
            }
            service.write_json(template, base)
            node = {"server_ip": "192.0.2.2", "passwd": "test-password",
                    "obfs": {"password": "test-obfs"}, "tls": {"server_name": "example.org"}}
            args = SimpleNamespace(template=str(template), sops="sops", secrets="encrypted.yaml",
                                   identity="identity.txt", sing_box="sing-box", port=19890)
            with patch.object(service.subprocess, "run", side_effect=[
                SimpleNamespace(returncode=0, stdout=json.dumps(node)),
                SimpleNamespace(returncode=0),
            ]) as run:
                path = service.render(args, directory, proxy_only=True)
            output = json.loads(path.read_text())
            self.assertEqual(output["outbounds"][0]["password"], "test-password")
            self.assertEqual(output["outbounds"][0]["obfs"]["password"], "test-obfs")
            self.assertEqual(output["inbounds"], [{"type": "mixed", "listen_port": 19890}])
            self.assertEqual(path.stat().st_mode & 0o777, 0o600)
            self.assertEqual(json.loads(template.read_text()), base)
            self.assertIn("--extract", run.call_args_list[0].args[0])
            self.assertEqual(run.call_args_list[0].kwargs["env"]["SOPS_AGE_KEY_FILE"], "identity.txt")


class PortAvailabilityTests(unittest.TestCase):
    def test_live_listener_is_rejected(self):
        with socket.socket() as listener:
            listener.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            listener.bind(("127.0.0.1", 0))
            listener.listen(1)
            with self.assertRaisesRegex(RuntimeError, "occupied"):
                service.check_port_available(listener.getsockname()[1])

    def test_closed_connections_do_not_block_restart(self):
        with socket.socket() as listener:
            listener.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            listener.bind(("127.0.0.1", 0))
            listener.listen(1)
            port = listener.getsockname()[1]
            with socket.create_connection(("127.0.0.1", port), timeout=2) as client:
                accepted, _ = listener.accept()
                accepted.close()  # Active close leaves server-side TIME_WAIT.
                self.assertEqual(client.recv(1), b"")
        service.check_port_available(port)


class TUNRouteTests(unittest.TestCase):
    def test_private_exclusion_must_not_cover_tun_dns(self):
        config = {"inbounds": [{"type": "tun", "address": ["172.19.0.1/30"],
                                "route_exclude_address": ["172.16.0.0/12"]}]}
        with self.assertRaisesRegex(RuntimeError, "overlap"):
            service.validate_tun_routes(config)

    def test_carved_exclusion_leaves_dns_in_tun(self):
        excluded = service.ipaddress.ip_network("172.16.0.0/12").address_exclude(
            service.ipaddress.ip_network("172.19.0.0/30")
        )
        config = {"inbounds": [{"type": "tun", "address": ["172.19.0.1/30"],
                                "route_exclude_address": list(map(str, excluded))}]}
        service.validate_tun_routes(config)

    def test_dns_address_must_match_tun_subnet(self):
        config = {"inbounds": [{"type": "tun", "address": ["172.20.0.1/30"]}]}
        with self.assertRaisesRegex(RuntimeError, "outside"):
            service.validate_tun_routes(config)


if __name__ == "__main__":
    unittest.main()
