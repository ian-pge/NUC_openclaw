{
  config,
  pkgs,
  lib,
  nix-openclaw,
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
  services.logind.killUserProcesses = false;

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
  home-manager.extraSpecialArgs = {inherit nix-openclaw;};
  home-manager.users.claw = import ./home/default.nix;

  system.stateVersion = "24.11";
}
