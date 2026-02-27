{
  description = "NixOS Flake for OpenClaw NUC";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

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
      specialArgs = {inherit nix-openclaw;};
      modules = [
        disko.nixosModules.disko
        ./disko.nix
        home-manager.nixosModules.home-manager
        ./configuration.nix
      ];
    };
  };
}
