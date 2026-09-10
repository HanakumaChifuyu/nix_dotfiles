{
  pkgs,
  credentials,
  tun,
}:
let
  rule-set-snapshot = import ./sing-box-rules.nix;
  cn-rule-set-tags = builtins.attrNames rule-set-snapshot.hashes;

  # Fetch at build time so service startup works without a live proxy or CDN.
  mkRuleSet = tag: {
    inherit tag;
    type = "local";
    format = "binary";
    path = toString (
      pkgs.fetchurl {
        name = "sing-box-${tag}.srs";
        urls = [
          "https://raw.githubusercontent.com/senshinya/singbox_ruleset/${rule-set-snapshot.revision}/rule/${tag}/${tag}.srs"
          "https://cdn.jsdelivr.net/gh/senshinya/singbox_ruleset@${rule-set-snapshot.revision}/rule/${tag}/${tag}.srs"
        ];
        hash = rule-set-snapshot.hashes.${tag};
      }
    );
  };

  # Explicit direct exceptions shared by DNS and routing. Domains only, no paths.
  # Upstream package registries use the default proxy unless explicitly listed.
  direct-domains = [
    "www.luogu.com.cn"
    "faroapi.com"
    "www.coalcloud.net"
    "cloudflare.com"
    "mirrors.aliyun.com"
    "mirrors.tuna.tsinghua.edu.cn"
    "mirrors.ustc.edu.cn"
    "repo.huaweicloud.com"
    "mirrors.cloud.tencent.com"
    "mirrors.163.com"
    "mirrors.sohu.com"
    "mirrors.zju.edu.cn"
    "mirrors.nju.edu.cn"
    "mirrors.pku.edu.cn"
    "mirrors.bfsu.edu.cn"
    "mirrors.cqu.edu.cn"
    "mirrors.dgut.edu.cn"
    "mirrors.hit.edu.cn"
    "mirrors.neu.edu.cn"
    "mirrors.nwafu.edu.cn"
    "mirrors.shu.edu.cn"
    "mirrors.tongji.edu.cn"
    "mirrors.xjtu.edu.cn"
    "mirrors.sjtug.sjtu.edu.cn"
    "mirror.nyist.edu.cn"
    "mirrors.wsyu.edu.cn"
    "mirrors.jlu.edu.cn"
    "mirrors.hust.edu.cn"
    "mirrors.neusoft.edu.cn"
    "mirrors.jxust.edu.cn"
    "docker.1ms.run"
    "proxy.vvvv.ee"
    "docker.mirrors.ustc.edu.cn"
    "registry.docker-cn.com"
    "hub-mirror.c.163.com"
    "mirror.baidubce.com"
    "pypi.tuna.tsinghua.edu.cn"
    "pypi.mirrors.ustc.edu.cn"
    "goproxy.cn"
    "goproxy.io"
    "proxy.golang.com.cn"
    "crates.io-index.cn"
    "flutter-io.cn"
    "storage.flutter-io.cn"
    "maven.aliyun.com"
    "registry.npmmirror.com"
    "api.deepseek.com"
    "api.siliconflow.cn"
    "open.bigmodel.cn"
    "openapi.xfyun.cn"
    "openapi-hk.xfyun.cn"
    "dashscope.aliyuncs.com"
    "api.moonshot.cn"
    "api.baichuan-ai.com"
    "api.minimax.chat"
    "api.zhipuai.cn"
    "api.stepfun.com"
    "api.doubao.com"
    "ark.cn-beijing.volces.com"
    "ark.cn-shanghai.volces.com"
    "console.volcengine.com"
    "coze.cn"
    "cc.bingj.com"
    "ruby.taobao.org"
    "registry.npm.taobao.org"
    "npm.taobao.org"
    "packagist.phpcomposer.com"
    "repo.packagist.org.cn"
    "composer.china.com"
    "packagist.laravel-china.org"
    "gitee.com"
    "code.aliyun.com"
    "ghproxy.com"
    "mirror.ghproxy.com"
    "gh-proxy.com"
    "gh.api.99988866.xyz"
    "github.moeyy.xyz"
    "doubao.com"
    "hanakuma.uk"
    "chinamobile.com"
    "deepseek.com"
    "benefits.chinaums.com"
    "tailscale.com"
    "steam.clngaa.com"
    "eccdnx.com"
    "pphimalayanrt.com"
    "sycontroller.com"
  ];
in
{
  log = {
    level = "info";
    timestamp = true;
  };
  dns = {
    servers = [
      {
        tag = "aliyun";
        type = "udp";
        server = "223.5.5.5";
      }
      {
        tag = "tailscale";
        type = "udp";
        server = "100.100.100.100";
      }
      {
        type = "fakeip";
        tag = "fakeip-dns";
        inet4_range = "198.18.0.0/15";
        inet6_range = "fc00::/18";
      }
    ];
    rules = [
      {
        domain_suffix = [ "ts.net" ];
        action = "route";
        server = "tailscale";
      }
      {
        rule_set = cn-rule-set-tags;
        action = "route";
        server = "aliyun";
      }
      {
        domain_suffix = direct-domains;
        action = "route";
        server = "aliyun";
      }
      {
        query_type = [
          "HTTPS"
          "SVCB"
        ];
        action = "predefined";
        rcode = "REFUSED";
      }
      {
        query_type = [
          "A"
          "AAAA"
        ];
        server = "fakeip-dns";
      }
    ];
    strategy = "prefer_ipv4";
    independent_cache = true;
    final = "aliyun";
  };
  inbounds = [
    {
      type = "mixed";
      tag = "mixed-in";
      listen = "127.0.0.1";
      listen_port = 7890;
    }
    tun
  ];
  outbounds = [
    {
      type = "direct";
      tag = "direct";
    }
    {
      type = "hysteria2";
      tag = "proxy";
      server = credentials.server;
      server_port = 8888;
      password = credentials.password;
      obfs = {
        type = "salamander";
        password = credentials.obfsPassword;
      };
      tls = {
        enabled = true;
        server_name = credentials.serverName;
      };
    }
  ];
  route = {
    default_domain_resolver = "aliyun";
    rule_set = map mkRuleSet cn-rule-set-tags;
    rules = [
      # Preserve MagicDNS even for queries arriving through mixed-in.
      {
        ip_cidr = [ "100.100.100.100/32" ];
        port = 53;
        outbound = "direct";
      }
      # Capture ordinary DNS before destination-IP or domain bypass rules.
      {
        port = 53;
        action = "hijack-dns";
      }
      {
        port = [ 41641 ];
        network = "udp";
        outbound = "direct";
      }
      {
        domain_suffix = [ "tailscale.com" ];
        outbound = "direct";
      }
      {
        domain_suffix = [ "ts.net" ];
        outbound = "direct";
      }
      {
        ip_cidr = [ "100.64.0.0/10" ];
        outbound = "direct";
      }
      {
        ip_cidr = [ "223.5.5.5" ];
        outbound = "direct";
      }
      {
        ip_cidr = [ "36.133.122.222/32" ];
        outbound = "direct";
      }
      {
        ip_cidr = [ "1.1.1.1" ];
        outbound = "proxy";
      }
      # Steam content servers use HTTP/80 and can redirect chunk requests
      # to bare CDN IPs.  Keep the store on the proxy (normally HTTPS/443),
      # but send those downloads directly.
      {
        process_name = [
          "steam"
          "steamwebhelper"
        ];
        network = "tcp";
        port = [ 80 ];
        outbound = "direct";
      }
      {
        action = "sniff";
      }
      {
        protocol = "dns";
        action = "hijack-dns";
      }
      {
        rule_set = cn-rule-set-tags;
        action = "route";
        outbound = "direct";
      }
      {
        domain_suffix = direct-domains;
        outbound = "direct";
      }
      {
        ip_is_private = true;
        outbound = "direct";
      }
    ];
    final = "proxy";
  };
  experimental = {
    cache_file = {
      enabled = true;
      path = "cache.db";
      store_fakeip = true;
    };
  };
}
