# OpenClaw NixOS NUC

NixOS flake for an Intel NUC running [OpenClaw](https://github.com/openclaw/openclaw) via Telegram, powered by OpenAI Codex (ChatGPT OAuth).

Built on [nix-openclaw](https://github.com/openclaw/nix-openclaw).

## Repo Structure

```
├── flake.nix              # Flake inputs + module wiring
├── configuration.nix      # Main system config (packages, nix settings, home-manager)
├── hardware.nix           # Boot & hardware
├── networking.nix         # Network & SSH
├── users.nix              # User accounts
├── disko.nix              # Disk partitioning
├── home/
│   └── default.nix        # Home Manager config (OpenClaw, shell, theme)
├── documents/
│   ├── AGENTS.md          # Agent behavior & boundaries
│   ├── SOUL.md            # Core personality
│   └── TOOLS.md           # Tool usage instructions
└── scripts/
    └── setup-openclaw.sh  # One-time interactive setup wizard
```

## Fresh Install

### 1. Boot NixOS installer USB on the NUC

### 2. Partition and install

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
Username: clawe
Password: clawe
```

Change password immediately: `passwd`

### 4. Clone and set up

```bash
git clone https://github.com/ian-pge/NUC_openclaw.git ~/NUC_openclaw
cd ~/NUC_openclaw
bash scripts/setup-openclaw.sh
```

The script asks for:
- **Gateway token** — press Enter to auto-generate (recommended)
- **Telegram bot token** — from [@BotFather](https://t.me/BotFather)
- **API keys** (optional) — only if you want Anthropic/OpenAI instead of ChatGPT OAuth

It writes everything to `~/.secrets/` — nothing goes into git.

### 5. Build and switch

```bash
sudo nixos-rebuild switch --flake .#nuc
```

### 6. Test it

Send a Telegram message to your bot. The gateway sends you a ChatGPT OAuth login link. Log in, and you're up and running.

## How Secrets Work

No secrets in git, no `--impure` flag needed.

- **Gateway token** — loaded at runtime via systemd `EnvironmentFile` from `~/.secrets/openclaw-gateway-env`
- **Telegram bot token** — read at runtime from `~/.secrets/telegram-bot-token`
- **Telegram user ID** — hardcoded in `home/default.nix` (not a secret)
- **ChatGPT OAuth tokens** — stored in `~/.openclaw/`, auto-refreshed

## Useful Commands

```bash
systemctl --user status openclaw-gateway    # service status
journalctl --user -u openclaw-gateway -f    # live logs
systemctl --user restart openclaw-gateway   # restart
sudo nixos-rebuild switch --rollback        # rollback
```
