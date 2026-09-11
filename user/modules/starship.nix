{ ... }:

{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = (builtins.fromTOML (builtins.readFile ../dotfiles/.config/starship.toml)) // {
      command_timeout = 1000;
    };
  };
}
