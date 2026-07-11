{
  config,
  lib,
  pkgs,
  ...
}:
let
  hy2-ip = config.sops.secrets."hysteria2/server_ip".path;
  hy2-passwd = config.sops.secrets."hysteria2/passwd".path;
  hy2-obfs-passwd = config.sops.secrets."hysteria2/obfs/password".path;
  hy2-tls-server_name = config.sops.secrets."hysteria2/tls/server_name".path;

  vl-reality-ip = config.sops.secrets."vless_reality/server_ip".path;
  vl-reality-uuid = config.sops.secrets."vless_reality/uuid".path;
  vl-reality-pubkey = config.sops.secrets."vless_reality/public_key".path;
  vl-reality-shortid = config.sops.secrets."vless_reality/short_id".path;

  cn-rule-set-tags = [
    "WeChat"
    "DingTalk"
    "BiliBili"
    "NetEaseMusic"
    "DouYin"
    "Weibo"
    "Zhihu"
    "XiaoHongShu"
    "MeiTuan"
    "JingDong"
    "Alibaba"
    "Baidu"
    "Tencent"
    "iQIYI"
    "Youku"
    "KuaiShou"
    "XianYu"
    "Pinduoduo"
    "XiaoMi"
    "Huawei"
    "Coolapk"
    "NGA"
    "Sina"
    "Sohu"
    "NetEase"
    "KugouKuwo"
    "Kingsoft"
    "KingsoftCloud"
    "XieCheng"
  ];

  mkRuleSet = tag: {
    inherit tag;
    type = "remote";
    format = "binary";
    url = "https://cdn.jsdelivr.net/gh/senshinya/singbox_ruleset@main/rule/${tag}/${tag}.srs";
    download_detour = "proxy";
  };

  cn-domains-dns = [
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
    "mirrors.tuna.tsinghua.edu.cn"
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
    "mirrors.ustc.edu.cn/crates.io-index"
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
  ];

  cn-domains-route-extra = [
    "coze.cn"
    "cc.bingj.com"
    "mirrors.xjtu.edu.cn"
    "mirrors.jlu.edu.cn"
    "mirrors.ustc.edu.cn"
    "mirrors.nju.edu.cn"
    "ruby.taobao.org"
    "registry.npm.taobao.org"
    "npm.taobao.org"
    "mirrors.aliyun.com/npm"
    "mirrors.aliyun.com/goproxy"
    "repo.spring.io"
    "plugins.gradle.org.mirror"
    "downloads.gradle-dn.com"
    "packagist.phpcomposer.com"
    "repo.packagist.org.cn"
    "composer.China.com"
    "packagist.laravel-china.org"
    "homebrew.bintray.com"
    "mirrors.tuna.tsinghua.edu.cn/homebrew"
    "mirrors.ustc.edu.cn/homebrew"
    "pypi.python.org"
    "gitee.com"
    "rubygems.org"
    "npmjs.org"
    "yarnpkg.com"
    "nuget.org"
    "chocolatey.org"
    "brew.sh"
    "linuxbrew.bintray.com"
    "sh.rustup.rs"
    "static.rust-lang.org"
    "mirrors.aliyun.com/crates.io-index"
    "mirrors.sjtug.sjtu.edu.cn/git/crates.io-index"
    "mirrors.tuna.tsinghua.edu.cn/git/crates.io-index"
    "code.aliyun.com"
    "mirrors.tuna.tsinghua.edu.cn/anaconda"
    "repo.anaconda.com"
    "conda.anaconda.org"
    "mirrors.tuna.tsinghua.edu.cn/anaconda/cloud"
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
  ];
in
{
  sops.secrets."hysteria2/server_ip" = { };
  sops.secrets."hysteria2/passwd" = { };
  sops.secrets."hysteria2/obfs/password" = { };
  sops.secrets."hysteria2/tls/server_name" = { };

  sops.secrets."vless_reality/server_ip" = { };
  sops.secrets."vless_reality/uuid" = { };
  sops.secrets."vless_reality/public_key" = { };
  sops.secrets."vless_reality/short_id" = { };

  services.sing-box = {
    enable = true;
    # enable = false;
    settings = {
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
            domain_suffix = cn-domains-dns;
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
        {
          type = "tun";
          tag = "tun-in";
          interface_name = "tun0";
          address = [
            "172.19.0.1/30"
            "fdfe:dcba:9876::1/126"
          ];
          mtu = 1350;
          stack = "system";
          auto_route = true;
          strict_route = true;
          auto_redirect = true;
          route_exclude_address = [ "100.64.0.0/10" ];
        }
      ];
      outbounds = [
        {
          type = "direct";
          tag = "direct";
        }
        {
          type = "hysteria2";
          tag = "proxy";
          server = {
            _secret = hy2-ip;
          };
          server_port = 8888;
          password = {
            _secret = hy2-passwd;
          };
          obfs = {
            type = "salamander";
            password = {
              _secret = hy2-obfs-passwd;
            };
          };
          tls = {
            enabled = true;
            server_name = {
              _secret = hy2-tls-server_name;
            };
          };
        }
        {
          type = "vless";
          tag = "reality-proxy";
          server = {
            _secret = vl-reality-ip;
          };
          server_port = 29191;
          uuid = {
            _secret = vl-reality-uuid;
          };
          flow = "xtls-rprx-vision";
          tls = {
            enabled = true;
            server_name = "www.microsoft.com";
            utls = {
              enabled = true;
              fingerprint = "chrome";
            };
            reality = {
              enabled = true;
              public_key = {
                _secret = vl-reality-pubkey;
              };
              short_id = {
                _secret = vl-reality-shortid;
              };
            };
          };
        }
      ];
      route = {
        default_domain_resolver = "aliyun";
        rule_set = map mkRuleSet cn-rule-set-tags;
        rules = [
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
          {
            action = "sniff";
          }
          {
            type = "logical";
            mode = "or";
            rules = [
              { protocol = "dns"; }
              { port = 53; }
            ];
            action = "hijack-dns";
          }
          {
            rule_set = cn-rule-set-tags;
            action = "route";
            outbound = "direct";
          }
          {
            domain_suffix = cn-domains-dns ++ cn-domains-route-extra;
            outbound = "direct";
          }
          {
            domain_keyword = [
              "mirror"
              "mirrors"
            ];
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
    };
  };
}
