{
  description = "NixOS Flake for OpenClaw NUC";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
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
