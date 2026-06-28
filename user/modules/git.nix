{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "HanakumaChifuyu";
        email = "ytchencheng@gmail.com";
      };

      init.defaultBranch = "main";
      pull.rebase = true;

    };
  };
}
