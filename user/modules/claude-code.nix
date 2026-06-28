{ config, ... }:

let
  home = toString config.home.homeDirectory;
in
{
  programs.claude-code = {
    enable = true;

    agentsDir = ../dotfiles/.claude/agents;
    commandsDir = ../dotfiles/.claude/commands;
  };

  sops.secrets = {
    "deepseek_key" = {
      key = "ai_api_keys/deepseek_ak";
    };
  };
  sops.templates."claude-code-settings.json" = {
    path = "${config.home.homeDirectory}/.claude/settings.json";
    content = ''
      {
        "skipDangerousModePermissionPrompt": true,

        "env": {
          "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
          "ANTHROPIC_AUTH_TOKEN": "${config.sops.placeholder."deepseek_key"}",
          "API_TIMEOUT_MS": "3000000",
          "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": 1,

          "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-pro",
          "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-pro",
          "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro"
        }
      }
    '';
  };

  home.file.".claude/rules".source = ../dotfiles/.claude/rules;
}
