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
    "open_router_ak" = {
      key = "ai_api_keys/open_router_ak";
    };

  };
  sops.templates."claude-code-settings.json" = {
    path = "${config.home.homeDirectory}/.claude/settings.json";
    content = ''
      {
        "skipDangerousModePermissionPrompt": true,

        "env": {
          "ANTHROPIC_BASE_URL": "https://openrouter.ai/api",
          "ANTHROPIC_AUTH_TOKEN": "${config.sops.placeholder."open_router_ak"}",
          "ANTHROPIC_API_KEY": "",
          "API_TIMEOUT_MS": "3000000",
          "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": 1,

          "ANTHROPIC_DEFAULT_HAIKU_MODEL": "z-ai/glm-5.2",
          "ANTHROPIC_DEFAULT_SONNET_MODEL": "z-ai/glm-5.2",
          "ANTHROPIC_DEFAULT_OPUS_MODEL": "z-ai/glm-5.2"
        }
      }
    '';

  };

  home.file.".claude/rules".source = ../dotfiles/.claude/rules;
}
