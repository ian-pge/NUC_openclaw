#!/usr/bin/env bash
# Run ONCE on a new machine before the first nixos-rebuild / home-manager switch.
# Writes secret files to ~/.secrets/ — read at service startup, never in git.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SECRETS_DIR="$HOME/.secrets"

echo ""
echo "==========================================="
echo "  OpenClaw First-Time Setup"
echo "==========================================="
echo ""

# --- Create secrets directory ------------------------------------------------
mkdir -p "$SECRETS_DIR"
chmod 700 "$SECRETS_DIR"

# --- 1. Gateway Token -------------------------------------------------------
echo "--- Gateway Auth Token ---"
echo ""

if [ -f "$SECRETS_DIR/openclaw-gateway-env" ] && grep -q "OPENCLAW_GATEWAY_TOKEN=" "$SECRETS_DIR/openclaw-gateway-env"; then
  echo "  Gateway token already configured in $SECRETS_DIR/openclaw-gateway-env. Skipping..."
  gw_token=$(grep "OPENCLAW_GATEWAY_TOKEN=" "$SECRETS_DIR/openclaw-gateway-env" | cut -d '=' -f 2)
else
  echo "  This secures communication with the OpenClaw gateway."
  echo "  Press Enter to auto-generate a random token (recommended)."
  echo ""

  printf "  Enter token (or Enter to generate): "
  read -r gw_token
  if [ -z "$gw_token" ]; then
    gw_token=$(od -An -tx1 -N24 /dev/urandom | tr -d ' \n')
    echo "  Generated: $gw_token"
  fi
fi

# --- 2. Telegram Bot Token ---------------------------------------------------
echo ""
echo "--- Telegram Bot Token ---"
echo ""

if [ -s "$SECRETS_DIR/telegram-bot-token" ]; then
  echo "  Telegram Bot token already exists in $SECRETS_DIR/telegram-bot-token. Skipping..."
  tg_bot_token=$(cat "$SECRETS_DIR/telegram-bot-token")
else
  echo "  Create a bot via @BotFather on Telegram and paste the token."
  echo ""

  printf "  Bot token: "
  read -r tg_bot_token
  if [ -z "$tg_bot_token" ]; then
    echo "  Error: bot token cannot be empty."
    exit 1
  fi
fi

# --- 3. LLM Provider (OAuth) --------------------------------------------------
echo ""
echo "--- LLM Provider ---"
echo ""
echo "  The default config uses OpenAI Codex via ChatGPT OAuth."
echo "  We will now trigger the secure browser login flow..."
echo ""

openclaw onboard --auth-choice openai-codex --skip-channels --skip-skills --skip-ui --skip-health


# --- Write secret files to ~/.secrets/ ----------------------------------------
printf 'OPENCLAW_GATEWAY_TOKEN=%s\n' "$gw_token" > "$SECRETS_DIR/openclaw-gateway-env"
chmod 600 "$SECRETS_DIR/openclaw-gateway-env"
echo ""
echo "  Saved -> $SECRETS_DIR/openclaw-gateway-env"

printf '%s' "$tg_bot_token" > "$SECRETS_DIR/telegram-bot-token"
chmod 600 "$SECRETS_DIR/telegram-bot-token"
echo "  Saved -> $SECRETS_DIR/telegram-bot-token"

# --- Restart Service -----------------------------------------------------------
echo "  Restarting the OpenClaw gateway service..."
systemctl --user restart openclaw-gateway || echo "  Warning: Failed to restart openclaw-gateway. Is it enabled?"

# --- Done --------------------------------------------------------------------
echo ""
echo "==========================================="
echo "  Setup complete!"
echo ""
echo "  Next steps:"
echo "    cd $REPO_DIR"
echo "    sudo nixos-rebuild switch --flake .#nuc"
echo ""
echo "  To view logs:"
echo "    journalctl --user -u openclaw-gateway -f"
echo "==========================================="
