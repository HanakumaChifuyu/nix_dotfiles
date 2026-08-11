{ server }: {
  log = {
    level = "info";
    timestamp = true;
  };
  inbounds = [
    {
      type = "hysteria2";
      tag = "hy2-in";
      listen = "::";
      listen_port = 8888;
      obfs = {
        type = "salamander";
        password = server.obf.passwd;
      };
      users = [
        {
          name = server.user.sekai.name;
          password = server.user.sekai.passwd;
        }
      ];
      ignore_client_bandwidth = false;
      tls = {
        enabled = true;
        server_name = server.tls.hostname;
        certificate_path = server.tls.certificate;
        key_path = server.tls.certificate_key;
      };
      masquerade = server.masquerade;
    }
  ];
  # "outbounds": [
  #   {
  #     "type": "direct",
  #     "tag": "direct"
  #   },
  #   {
  #     "type": "block",
  #     "tag": "block"
  #   }
  # ],
  # "route": {
  #   "rules": [
  #     {
  #       "protocol": "dns",
  #       "outbound": "direct"
  #     }
  #   ]
  # }
}
