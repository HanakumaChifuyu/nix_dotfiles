{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };

      racknerdVPS = {
        Hostname = "172.245.224.190";
        User = "root";
        Port = 22;
      };

      home_lan = {
        Hostname = "192.168.1.8";
        User = "chifuyu";
        Port = 22;
      };

      hanakuma = {
        Hostname = "100.67.85.84";
        User = "chifuyu";
        Port = 22;
      };

      hairun = {
        Hostname = "10.10.21.111";
        User = "hairun";
        Port = 22;
      };

      nas = {
        Hostname = "hanakuma.uk";
        User = "tohno";
        Port = 2233;
      };

      hairun_ubuntu = {
        Hostname = "100.94.13.18";
        User = "hairun";
      };

      evoxt = {
        Hostname = "166.88.114.68";
        User = "root";
      };

      "github.com" = {
        Hostname = "github.com";
        User = "git";
        ProxyCommand = "nc -X 5 -x 127.0.0.1:7890 %h %p";
      };

      yidocloud = {
        Hostname = "36.133.122.222";
        User = "root";
        Port = 3515;
      };

      "gitee.com" = {
        Hostname = "gitee.com";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
        PreferredAuthentications = "publickey";
      };

      nvxdg = {
        Hostname = "100.87.162.105";
        User = "hairun";
      };
    };
  };
}
