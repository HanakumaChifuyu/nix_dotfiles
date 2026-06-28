{ config, ... }:
{

  nix.registry = {
    rust_basic.to = {
      type = "github";
      owner = "HanakumaChifuyu";
      repo = "rust_basic";
    };
    templates.to = {
      type = "path";
      path = "${../../template}";
    };
  };
}
