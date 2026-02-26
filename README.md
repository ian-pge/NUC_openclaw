# OpenClaw NixOS NUC Deployment

This repository contains the declarative NixOS configuration to automatically deploy a base operating system for an OpenClaw agent on an Intel NUC. It utilizes disko for zero-touch disk partitioning and formatting.

## Warning
Running the installation command below will completely wipe the target drive (/dev/sda by default). Ensure you are running this on the correct NUC and have backed up any necessary data before proceeding.

## Installation Instructions

1. Boot the Intel NUC using a NixOS Live USB. Ensure UEFI boot is enabled and Legacy boot is disabled in the NUC's BIOS.

2. Once you reach the NixOS terminal, temporarily load Git into the live environment:
nix-shell -p git

3. Clone this repository and move into the directory:
git clone https://github.com/ian-pge/NUC_openclaw.git
cd NUC_openclaw

4. Run the automated disk formatter and system installer:
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko disko.nix && sudo nixos-install --flake .#nuc

5. Wait for the installation to complete. You will be prompted to set a root password at the end. 

6. Type reboot, press Enter, and remove your USB drive. 

## Access
By default, this configuration enables OpenSSH and creates an admin user. Once booted, you can SSH into the NUC from your primary machine to manage the OpenClaw environment remotely.
