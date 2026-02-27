# 🖥️ OpenClaw NixOS NUC Deployment

This guide walks you through installing OpenClaw on an Intel NUC using NixOS, flakes, and Disko.

---

## 📦 1. Installation

### Step 1 — Boot the NixOS Installer

1. Flash the latest NixOS ISO to a USB drive.
2. Insert the USB into your Intel NUC.
3. Boot from the USB device.

---

### Step 2 — Clone the Repository

Open a terminal in the NixOS live environment and run:

```bash
nix-shell -p git
git clone https://github.com/ian-pge/NUC_openclaw.git
cd NUC_openclaw
```

---

### Step 3 — Partition & Install (Disko + Flakes)

Run:

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko disko.nix && \
sudo nixos-install --flake .#nuc
```

This will:
- Partition and format the disk using Disko
- Install NixOS using the provided flake configuration

When prompted:
- Set your **root password**
- Type:

```bash
reboot
```

⚠️ Important: Remove the USB drive before rebooting.

---

## 🔐 2. First Login & Security

After reboot, log in with the default credentials:

Username: claw  
Password: claw  

Immediately change the password:

```bash
passwd
```

---

## 🌐 3. Remote Access (SSH)

Managing the NUC remotely makes it easier to copy and paste OpenClaw commands.

### Step 1 — Find the NUC IP Address

On the NUC:

```bash
ip a
```

Look for an address like:

192.168.x.x

---

### Step 2 — Connect from Your Main Computer

On your main machine:

```bash
ssh claw@<NUC_IP_ADDRESS>
```

Example:

```bash
ssh claw@192.168.1.42
```

If prompted to trust the host, type:

yes

---

## ✅ Setup Complete

Your OpenClaw NUC system is now:
- Installed with NixOS
- Secured with a new password
- Accessible remotely via SSH

You’re ready to deploy and manage OpenClaw.
