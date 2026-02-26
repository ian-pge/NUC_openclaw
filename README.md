# OpenClaw NixOS NUC Deployment

This repository contains the declarative NixOS configuration to automatically deploy a base operating system for an OpenClaw agent on an Intel NUC. It utilizes `disko` for zero-touch disk partitioning and formatting.

## ⚠️ Warning
Running the installation command below will **completely wipe** the target drive (`/dev/sda` by default). Ensure you are running this on the correct NUC and have backed up any necessary data before proceeding.

## Installation Instructions

1. Boot the Intel NUC using a NixOS Live USB. Ensure **UEFI boot** is enabled and **Legacy boot** is disabled in the NUC's BIOS.
2. Once you reach the NixOS terminal, temporarily load Git into the live environment:
   ```bash
   nix-shell -p git
