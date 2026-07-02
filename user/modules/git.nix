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

      http.proxy = "http://127.0.0.1:7890";
      https.proxy = "http://127.0.0.1:7890";
      # Bypass proxy for local/private hosts
      http."http://localhost/".proxy = "";
      http."http://127.0.0.1/".proxy = "";
    };
  };
}
