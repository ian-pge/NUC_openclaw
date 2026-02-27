# OpenClaw NixOS NUC

NixOS flake for an Intel NUC running [OpenClaw](https://github.com/openclaw/openclaw) — a personal AI assistant accessible via Telegram, powered by OpenAI Codex (ChatGPT OAuth).

## Repo Structure

```
├── flake.nix              # Flake inputs + module wiring
├── configuration.nix      # Main system config (packages, nix settings, home-manager)
├── hardware.nix           # Boot & hardware
├── networking.nix         # Network & SSH
├── users.nix              # User accounts
├── disko.nix              # Disk partitioning
├── home/
│   └── default.nix        # Home Manager config (OpenClaw lives here)
├── documents/
│   ├── AGENTS.md          # Agent behavior & boundaries
│   ├── SOUL.md            # Core personality
│   └── TOOLS.md           # Tool usage instructions
└── scripts/
    ├── setup-openclaw.sh  # One-time interactive setup (OAuth + Telegram)
    └── deploy.sh          # Pull from GitHub + rebuild
```

---

## Fresh Install (from scratch)

### 1. Boot NixOS installer USB on the NUC

### 2. Clone and install

```bash
nix-shell -p git
git clone https://github.com/ian-pge/NUC_openclaw.git
cd NUC_openclaw

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko disko.nix && \
sudo nixos-install --flake .#nuc
```

Set root password when prompted, then `reboot` (remove USB first).

### 3. First login

```
Username: claw
Password: claw
```

Change password immediately: `passwd`

### 4. Set up OpenClaw (one time)

```bash
cd /path/to/NUC_openclaw
bash scripts/setup-openclaw.sh
```

This walks you through:
- **ChatGPT OAuth** — links your ChatGPT subscription as the model provider
- **Telegram pairing** — authenticate to connect Telegram

### 5. Test it

Send a Telegram message to your bot — it should respond!

---

## Day-to-Day Workflow

**Edit on GitHub -> pull on NUC -> rebuild.**

From your laptop/phone, edit any file in this repo on GitHub. Then SSH into the NUC:

```bash
ssh claw@<NUC_IP>
cd /path/to/NUC_openclaw
bash scripts/deploy.sh
```

Or manually:

```bash
git pull
sudo nixos-rebuild switch --flake .#nuc
```

---

## Useful Commands

```bash
# Service status
systemctl --user status openclaw-gateway

# Live logs
journalctl --user -u openclaw-gateway -f

# Health check
openclaw doctor

# Re-authenticate Telegram (if session expires)
openclaw channels login

# Restart gateway
systemctl --user restart openclaw-gateway

# Rollback to previous config
sudo nixos-rebuild switch --rollback
```

### Telegram slash commands

Send these in your Telegram chat with the bot:

- `/status` — session info, model, token usage
- `/model openai/gpt-5.2` — switch model

---

## Security Notes

- Secrets (OAuth tokens, session data) live in `~/.openclaw/` on the NUC — never in this repo
- `.gitignore` excludes secrets and runtime state
- SSH is password-enabled by default — consider switching to key-only auth
- For production secrets, look into [agenix](https://github.com/ryantm/agenix) or [sops-nix](https://github.com/Mic92/sops-nix)

---

## Important: Post-Install Recommendations

### Give sudo access to OpenClaw

It is recommended to give the `claw` user passwordless sudo so OpenClaw can run `nixos-rebuild` and other system commands autonomously. Add this to `users.nix` or configure it after install.

### Do not store personal data on this machine

This NUC is dedicated to running OpenClaw. Do not store personal files, credentials, or sensitive data on it beyond what OpenClaw needs to operate.

### Separate NixOS and OpenClaw configs into two repos

After the initial setup, you should split things into two separate repositories:

1. **NixOS system config** — this repo (`flake.nix`, `configuration.nix`, `hardware.nix`, etc.)
2. **OpenClaw agent config** — a new repo containing `documents/`, plugins, and any agent-specific configuration

Create a **new GitHub profile** dedicated to your OpenClaw instance and push both repos there. Point OpenClaw at the agent config repo — that becomes the repo OpenClaw reads from and commits to going forward.

This repo is only for the initial NUC setup and system-level NixOS changes. Day-to-day OpenClaw configuration should live in the dedicated agent repo.
