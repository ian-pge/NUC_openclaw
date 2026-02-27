# Home Manager config for user "claw" — OpenClaw with WhatsApp + Codex
{ config, pkgs, nix-openclaw, ... }:

{
  imports = [
    nix-openclaw.homeManagerModules.default
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
      # -- WhatsApp --
      # After first deploy, pair your phone with: openclaw channels login
      channels.whatsapp = {
        dmPolicy = "pairing"; # Approve each new chat partner
        # After pairing, optionally restrict:
        # allowFrom = [ "whatsapp:336XXXXXXXX@s.whatsapp.net" ];
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
          "openai/codex" = { alias = "Codex"; };
          # Uncomment to add more models to the /model allowlist:
          # "openai/gpt-5.2" = { alias = "GPT"; };
          # "anthropic/claude-sonnet-4-5" = { alias = "Sonnet"; };
        };
      };
    };

    # -- Built-in plugins --
    firstParty = {
      summarize.enable = true;  # Summarize URLs, PDFs, videos
      oracle.enable = true;     # Web search
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
