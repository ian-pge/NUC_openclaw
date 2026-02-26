{
  description = "NixOS Flake for OpenClaw NUC";

  inputs = {
    # Using unstable to match your 25.11 installation ISO
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # The Disko tool for automated partitioning
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, ... }: {
    nixosConfigurations.nuc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        ./disko.nix
        ({ config, pkgs, lib, ... }: {
          
          # --- Hardware & Boot ---
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
          # Standard kernel modules to ensure the NUC can read its drives and USBs
          boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
          hardware.enableRedistributableFirmware = true;

          # --- Networking ---
          networking.hostName = "openclaw-nuc";
          networking.networkmanager.enable = true;

          # --- SSH (Remote Access) ---
          services.openssh = {
            enable = true;
            settings.PasswordAuthentication = true; # Allows you to log in with a password initially
          };

          # --- Users ---
          users.users.claw = {
            isNormalUser = true;
            description = "OpenClaw Admin";
            extraGroups = [ "networkmanager" "wheel" ];
            initialPassword = "claw"; # CHANGE THIS ONCE YOU LOG IN!
          };

          # --- System Settings ---
          nixpkgs.config.allowUnfree = true;
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          
          # Essential system packages
          environment.systemPackages = with pkgs; [
            git
            curl
            nano
            htop
          ];

          system.stateVersion = "24.11"; 
        })
      ];
    };
  };
}
