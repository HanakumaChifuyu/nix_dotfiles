# Git Platforms
{
  "github.com" = {
    Hostname = "github.com";
    User = "git";
    ProxyCommand = "nc -X 5 -x 127.0.0.1:7890 %h %p";
  };

  "gitee.com" = {
    Hostname = "gitee.com";
    User = "git";
    IdentityFile = "~/.ssh/id_ed25519";
    PreferredAuthentications = "publickey";
  };
}
