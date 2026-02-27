{
  description = "NixOS Flake for OpenClaw NUC";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Home Manager (manages user-level config including OpenClaw)
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Official OpenClaw Nix module
    nix-openclaw.url = "github:openclaw/nix-openclaw";
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    home-manager,
    nix-openclaw,
    ...
  }: {
    nixosConfigurations.nuc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        ./disko.nix

        # Home Manager as a NixOS module
        home-manager.nixosModules.home-manager

        ({
          config,
          pkgs,
          lib,
          ...
        }: {
          programs.nix-ld = {
            enable = true;
            libraries = with pkgs; [
              stdenv.cc.cc
              zlib
              openssl
              libcap
            ];
          };

          nixpkgs.overlays = [nix-openclaw.overlays.default];

          # --- Hardware & Boot ---
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
          boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
          hardware.enableRedistributableFirmware = true;

          # --- Networking ---
          networking.hostName = "openclaw-nuc";
          networking.networkmanager.enable = true;

          # --- SSH (Remote Access) ---
          services.openssh = {
            enable = true;
            settings.PasswordAuthentication = true;
          };

          # --- Users ---
          users.users.claw = {
            isNormalUser = true;
            description = "OpenClaw Admin";
            extraGroups = ["networkmanager" "wheel"];
            initialPassword = "claw"; # CHANGE THIS ONCE YOU LOG IN!
            linger = true; # Keep user services running after logout (needed for OpenClaw)
          };

          # --- System Settings ---
          nixpkgs.config.allowUnfree = true;
          nix.settings.experimental-features = ["nix-command" "flakes"];

          # Keep user services alive after SSH disconnect
          services.logind.killUserProcesses = false;

          environment.systemPackages = with pkgs; [
            git
            curl
            nano
            htop
            nodejs_22 # Required by OpenClaw
            pnpm # Required by OpenClaw
            jq # Used by OpenClaw skills
            ffmpeg # Media processing for OpenClaw
          ];

          # --- Home Manager ---
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit nix-openclaw;};
          home-manager.users.claw = import ./home/default.nix;

          system.stateVersion = "24.11";
        })
      ];
    };
  };
}
