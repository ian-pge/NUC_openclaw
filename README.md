1. Boot the NixOS USB on the NUC.

2. Run these commands exactly as written:

nix-shell -p git

git clone https://github.com/ian-pge/NUC_openclaw.git

cd NUC_openclaw

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko disko.nix && sudo nixos-install --flake .#nuc

3. When it finishes, type a root password, then type `reboot`.
