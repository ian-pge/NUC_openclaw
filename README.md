# OpenClaw NixOS Setup

Boot the NixOS USB on the NUC, then run the following commands:

    nix-shell -p git
    git clone https://github.com/ian-pge/NUC_openclaw.git
    cd NUC_openclaw
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko disko.nix && sudo nixos-install --flake .#nuc

When prompted at the end, set your root password and reboot.
