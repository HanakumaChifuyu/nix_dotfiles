{ lib, ... }:

{
  system.activationScripts.preActivation.text = lib.mkBefore ''
    if [ -x /opt/homebrew/bin/brew ]; then
      echo "Homebrew is already installed at /opt/homebrew/bin/brew."
    else
      echo "Homebrew is not installed; nix-homebrew will set it up during activation."
    fi
  '';

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "mac";
    autoMigrate = true;
  };

  homebrew = {
    enable = true;

    casks = [
      "karabiner-elements"
      "squirrel-app"
      "wechat"
    ];

    onActivation = {
      autoUpdate = true;
      upgrade = false;
      cleanup = "none";
    };
  };
}
