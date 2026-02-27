# Home Manager config for user "claw" — OpenClaw with Telegram + Codex
{
  config,
  pkgs,
  nix-openclaw,
  ...
}: {
  imports = [
    nix-openclaw.homeManagerModules.openclaw
  ];

  home.username = "claw";
  home.homeDirectory = "/home/claw";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # ---------------------------------------------------------------------------
  # OpenClaw
  # ---------------------------------------------------------------------------
  programs.openclaw = {
    enable = true;

    # Agent personality docs (version-controlled in this repo)
    documents = ../documents;

    config = {
      # -- Telegram --
      # After first deploy, authenticate with: openclaw channels login
      channels.telegram = {
        dmPolicy = "pairing";
      };

      # -- Model: OpenAI Codex via ChatGPT OAuth --
      # After first deploy, authenticate with: openclaw onboard
      # Choose OpenAI → ChatGPT (OAuth) when prompted
      agents.defaults = {
        model = {
          primary = "openai/codex";
          # fallbacks = [ "openai/gpt-5.2" ];
        };
        models = {
          "openai/codex" = {alias = "Codex";};
          # Uncomment to add more models to the /model allowlist:
          # "openai/gpt-5.2" = { alias = "GPT"; };
          # "anthropic/claude-sonnet-4-5" = { alias = "Sonnet"; };
        };
      };
    };

    bundledPlugins = {
      summarize.enable = true; # optional but useful
      # add more later if you want
    };

    # -- Community plugins --
    # plugins = [
    #   { source = "github:owner/some-plugin"; }
    # ];
  };

  # Extra packages available in claw's shell
  home.packages = with pkgs; [
    ripgrep
  ];
}
