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

      # Lazygit delegates conflict resolution to `git mergetool`.
      # nvimdiff opens LOCAL, BASE, and REMOTE above the editable MERGED result.
      merge.tool = "nvimdiff";
      mergetool = {
        prompt = false;
        keepBackup = false;
        nvimdiff.layout = "LOCAL,BASE,REMOTE / MERGED";
      };

      http.proxy = "http://127.0.0.1:7890";
      https.proxy = "http://127.0.0.1:7890";
      # Bypass proxy for local/private hosts
      http."http://localhost/".proxy = "";
      http."http://127.0.0.1/".proxy = "";
    };
  };
}
