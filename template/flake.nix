{
  description = "A basic Nix Flake devShell templates";

  outputs =
    { self }:
    {
      templates = {
        template = {
          path = ./default;

          description = "A very basic dev flake";
        };
      };

      defaultTemplate = self.templates.template;
    };
}
