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
echo "  This secures communication with the OpenClaw gateway."
echo "  Press Enter to auto-generate a random token (recommended)."
echo ""

printf "  Enter token (or Enter to generate): "
read -r gw_token
if [ -z "$gw_token" ]; then
  gw_token=$(od -An -tx1 -N24 /dev/urandom | tr -d ' \n')
  echo "  Generated: $gw_token"
fi

# --- 2. Telegram Bot Token ---------------------------------------------------
echo ""
echo "--- Telegram Bot Token ---"
echo ""
echo "  Create a bot via @BotFather on Telegram and paste the token."
echo ""

printf "  Bot token: "
read -r tg_bot_token
if [ -z "$tg_bot_token" ]; then
  echo "  Error: bot token cannot be empty."
  exit 1
fi

# --- 3. LLM Provider (optional API keys) ------------------------------------
echo ""
echo "--- LLM Provider ---"
echo ""
echo "  The default config uses OpenAI Codex via ChatGPT OAuth."
echo "  After rebuild, the gateway will prompt you to log in via Telegram."
echo "  No API key needed unless you want a different provider."
echo ""

printf "  Anthropic API key (or Enter to skip): "
read -r anthropic_key
if [ -n "$anthropic_key" ]; then
  printf '%s' "$anthropic_key" > "$SECRETS_DIR/anthropic-api-key"
  chmod 600 "$SECRETS_DIR/anthropic-api-key"
  echo "  Saved -> $SECRETS_DIR/anthropic-api-key"
fi

printf "  OpenAI API key (or Enter to skip): "
read -r openai_key
if [ -n "$openai_key" ]; then
  printf '%s' "$openai_key" > "$SECRETS_DIR/openai-api-key"
  chmod 600 "$SECRETS_DIR/openai-api-key"
  echo "  Saved -> $SECRETS_DIR/openai-api-key"
fi

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
