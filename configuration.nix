{
  config,
  pkgs,
  lib,
  nix-openclaw,
  catppuccin,
  ...
}: {
  imports = [
    ./hardware.nix
    ./networking.nix
    ./users.nix
  ];

  # --- Nix Settings ---
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [nix-openclaw.overlays.default];
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # --- Automatic Updates ---
  system.autoUpgrade = {
    enable = true;
    flake = "github:ian-pge/NUC_openclaw#nuc";
    allowReboot = false;
  };

  # --- Garbage Collection ---
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # --- nix-ld ---
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
      libcap
    ];
  };

  # --- Session / Logind ---
  services.logind.settings.Login.KillUserProcesses = false;

  # --- System Packages ---
  environment.systemPackages = with pkgs; [
    git
    curl
    nano
    htop
    nodejs_22
    pnpm
    jq
    ffmpeg
  ];

  # --- Home Manager ---
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-backup";
  home-manager.extraSpecialArgs = {inherit nix-openclaw catppuccin;};
  home-manager.users.clawe = import ./home/default.nix;

  system.stateVersion = "24.11";
}
