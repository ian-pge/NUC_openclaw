# Home Manager config for user "clawe" — OpenClaw with Telegram + Codex
{
  config,
  pkgs,
  nix-openclaw,
  catppuccin,
  ...
}: {
  imports = [
    nix-openclaw.homeManagerModules.openclaw
    catppuccin.homeModules.catppuccin
  ];

  home.username = "clawe";
  home.homeDirectory = "/home/clawe";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # Force OpenClaw to start on headless boot instead of waiting for a GUI
  systemd.user.services.openclaw-gateway = {
    Unit = {
      After = ["network-online.target"];
      Description = "OpenClaw Gateway Service";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  # ---------------------------------------------------------------------------
  # OpenClaw
  # ---------------------------------------------------------------------------
  programs.openclaw = {
    enable = true;

    # Agent personality docs (version-controlled in this repo)
    documents = ../documents;

    config = {
      gateway.mode = "local";

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

  # ---------------------------------------------------------------------------
  # Catppuccin theme
  # ---------------------------------------------------------------------------
  catppuccin.fish = {
    enable = true;
    flavor = "macchiato";
  };
  catppuccin.fzf = {
    enable = true;
    flavor = "macchiato";
    accent = "sapphire";
  };

  # ---------------------------------------------------------------------------
  # Shell (Fish + Starship + fzf)
  # ---------------------------------------------------------------------------
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      functions -q prompt_newline; and prompt_newline >/dev/null
      fish_vi_key_bindings
      bind yy fish_clipboard_copy
      bind -M visual y fish_clipboard_copy
    '';
    functions = {
      starship_transient_prompt_func.body = "starship module time";
      prompt_newline = {
        onEvent = "fish_postexec";
        body = "echo";
      };
    };
    plugins = [
      {
        name = "bass";
        src = pkgs.fishPlugins.bass.src;
      }
    ];
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableTransience = true;
    settings = {
      add_newline = false;
      format = "$os $username@$hostname $directory $git_branch$line_break$character\n";
      palette = "catppuccin";
      right_format = "$cmd_duration";

      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](fg:red)";
        vimcmd_symbol = "[❮](fg:peach)";
        vimcmd_visual_symbol = "[❮](fg:mauve)";
        vimcmd_replace_symbol = "[❮](fg:sky)";
        vimcmd_replace_one_symbol = "[❮](fg:pink)";
      };

      cmd_duration = {
        min_time = 0;
        show_milliseconds = true;
        style = "fg:peach";
        format = "[$duration]($style)";
      };

      container = {
        symbol = " ";
        style = "fg:maroon";
        format = "[$symbol$container]($style) ";
      };

      directory = {
        truncation_length = 0;
        truncate_to_repo = false;
        home_symbol = "~";
        style = "fg:flamingo";
        read_only = " ";
        read_only_style = "fg:flamingo";
        format = "[$read_only]($read_only_style)[$path]($style)";
        repo_root_format = "[$read_only]($read_only_style)[$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($repo_root_style)";
        before_repo_root_style = "fg:flamingo";
        repo_root_style = "fg:teal";
      };

      git_branch = {
        symbol = " ";
        style = "fg:teal";
        format = "[$symbol$branch]($style) ";
      };

      hostname = {
        ssh_only = false;
        style = "fg:mauve";
        format = "[$hostname]($style)";
      };

      os = {
        disabled = false;
        style = "fg:sky";
        format = "[$symbol]($style)";
        symbols = {
          NixOS = "";
          Ubuntu = "";
          Arch = "";
          Fedora = "";
          Debian = "";
        };
      };

      palettes.catppuccin = {
        blue = "#8AADF4";
        flamingo = "#f0c6c6";
        green = "#a6da95";
        lavender = "#B7BDF8";
        maroon = "#ee99a0";
        mauve = "#c6a0f6";
        os = "#ACB0BE";
        peach = "#F5A97F";
        pink = "#F5BDE6";
        rosewater = "#f4dbd6";
        sapphire = "#7dc4e4";
        sky = "#91d7e3";
        teal = "#8bd5ca";
        yellow = "#eed49f";
      };

      time = {
        disabled = false;
        time_format = "%H:%M";
        style = "fg:yellow";
        format = "[$time]($style) ";
      };

      username = {
        show_always = true;
        style_user = "fg:pink";
        style_root = "fg:red";
        format = "[$user]($style)";
      };
    };
  };

  # Extra packages available in clawe's shell
  home.packages = with pkgs; [
    ripgrep
  ];
}
