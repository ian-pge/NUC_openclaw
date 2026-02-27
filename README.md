# 🖥️ OpenClaw NixOS NUC

NixOS flake for an Intel NUC running [OpenClaw](https://github.com/openclaw/openclaw) — a personal AI assistant accessible via WhatsApp, powered by OpenAI Codex (ChatGPT OAuth).

## Repo Structure

```
├── flake.nix              # NixOS flake (system + home-manager + openclaw)
├── disko.nix              # Disk partitioning
├── home/
│   └── default.nix        # Home Manager config (OpenClaw lives here)
├── documents/
│   ├── AGENTS.md          # Agent behavior & boundaries
│   ├── SOUL.md            # Core personality
│   └── TOOLS.md           # Tool usage instructions
└── scripts/
    ├── setup-openclaw.sh  # One-time interactive setup (OAuth + WhatsApp QR)
    └── deploy.sh          # Pull from GitHub + rebuild
```

---

## 📦 Fresh Install (from scratch)

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
- **ChatGPT OAuth** — links your $20/mo ChatGPT subscription as the model provider
- **WhatsApp QR pairing** — scan with your phone to connect WhatsApp

### 5. Test it

Send a WhatsApp message to yourself — your bot should respond!

---

## 🔄 Day-to-Day Workflow

**Edit on GitHub → pull on NUC → rebuild.**

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

## 🛠️ Useful Commands

```bash
# Service status
systemctl --user status openclaw-gateway

# Live logs
journalctl --user -u openclaw-gateway -f

# Health check
openclaw doctor

# Re-pair WhatsApp (if session expires)
openclaw channels login

# Restart gateway
systemctl --user restart openclaw-gateway

# Rollback to previous config
# (list generations, then switch)
sudo nixos-rebuild switch --rollback
```

### WhatsApp slash commands

Send these in your WhatsApp chat with the bot:

- `/status` — session info, model, token usage
- `/model openai/gpt-5.2` — switch model

---

## 🔐 Security Notes

- Secrets (OAuth tokens, session data) live in `~/.openclaw/` on the NUC — never in this repo
- `.gitignore` excludes secrets and runtime state
- SSH is password-enabled by default — consider switching to key-only auth
- For production secrets, look into [agenix](https://github.com/ryantm/agenix) or [sops-nix](https://github.com/Mic92/sops-nix)
