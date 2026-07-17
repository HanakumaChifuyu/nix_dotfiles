{ ... }:

let
  proxyUrl = "http://127.0.0.1:7890";
  noProxy = "127.0.0.1,localhost,::1,100.64.0.0/10,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16";
in
{
  home.sessionVariables = {
    http_proxy = proxyUrl;
    https_proxy = proxyUrl;
    all_proxy = "socks5://127.0.0.1:7890";
    HTTP_PROXY = proxyUrl;
    HTTPS_PROXY = proxyUrl;
    ALL_PROXY = "socks5://127.0.0.1:7890";
    no_proxy = noProxy;
    NO_PROXY = noProxy;
  };
}
