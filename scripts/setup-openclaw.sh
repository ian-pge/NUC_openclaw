#!/usr/bin/env bash
# Run ONCE on the NUC after first nixos-rebuild to handle interactive steps.
set -euo pipefail

SECRETS_DIR="/var/lib/secrets/openclaw"

echo ""
echo "═══════════════════════════════════════════════"
echo "  OpenClaw Setup — One-Time Interactive Steps"
echo "═══════════════════════════════════════════════"
echo ""

# --- Create secrets directory ---
if [ ! -d "$SECRETS_DIR" ]; then
    echo "Creating secrets directory at $SECRETS_DIR ..."
    sudo mkdir -p "$SECRETS_DIR"
    sudo chown "$(whoami):users" "$SECRETS_DIR"
    sudo chmod 700 "$SECRETS_DIR"
fi

echo "━━━ Step 1: Model Provider (ChatGPT OAuth) ━━━"
echo ""
echo "When prompted, choose:"
echo "  Provider → OpenAI"
echo "  Auth     → ChatGPT (OAuth)"
echo ""
echo "You'll get a URL to open in a browser."
echo "If NUC is headless, check which port openclaw is listening on:"
echo "  ss -tlnp"
echo "Then from your laptop, forward that port:"
echo "  ssh -L <PORT>:localhost:<PORT> clawe@<NUC_IP>"
echo "Open the URL on your laptop and paste the redirect back."
echo ""
read -p "Press Enter to start onboarding..."
openclaw onboard || echo "⚠ Onboarding exited. Re-run with: openclaw onboard"

echo ""
echo "━━━ Step 2: Telegram Pairing ━━━"
echo ""
echo "Follow the prompts to authenticate with Telegram."
echo ""
read -p "Press Enter to start Telegram pairing..."
openclaw channels login || echo "⚠ Pairing exited. Re-run with: openclaw channels login"

echo ""
echo "━━━ Step 3: Persist Credentials ━━━"
echo ""
echo "Saving tokens so they survive reboots..."

# Save gateway token
GW_TOKEN=$(openclaw config get gateway.auth.token 2>/dev/null || true)
if [ -n "$GW_TOKEN" ]; then
    echo "OPENCLAW_GATEWAY_TOKEN=$GW_TOKEN" > "$SECRETS_DIR/env"
    chmod 600 "$SECRETS_DIR/env"
    echo "✅ Gateway token saved"
else
    echo "⚠ Could not read gateway token"
fi

# Save Telegram credentials (stored in state dir, not the JSON)
TELEGRAM_STATE="$HOME/.openclaw/channels/telegram"
if [ -d "$TELEGRAM_STATE" ]; then
    cp -a "$TELEGRAM_STATE" "$SECRETS_DIR/telegram-state"
    chmod -R 600 "$SECRETS_DIR/telegram-state"
    chmod 700 "$SECRETS_DIR/telegram-state"
    echo "✅ Telegram state saved"
else
    echo "⚠ No Telegram state directory found"
fi

# Save OpenAI/model credentials from the config before home-manager overwrites it
OPENAI_KEY=$(openclaw config get agents.defaults.model.credentials.apiKey 2>/dev/null || true)
if [ -n "$OPENAI_KEY" ]; then
    echo "OPENAI_API_KEY=$OPENAI_KEY" >> "$SECRETS_DIR/env"
    echo "✅ OpenAI credentials saved"
fi

# Backup the entire config as a reference
cp "$HOME/.openclaw/openclaw.json" "$SECRETS_DIR/openclaw.json.reference" 2>/dev/null || true
echo "✅ Config snapshot saved to $SECRETS_DIR/openclaw.json.reference"
echo ""
echo "━━━ Step 4: Verify ━━━"
echo ""

if systemctl --user is-active --quiet openclaw-gateway 2>/dev/null; then
    echo "✅ openclaw-gateway is running!"
else
    echo "Starting openclaw-gateway..."
    systemctl --user start openclaw-gateway 2>/dev/null || true
    sleep 3
    if systemctl --user is-active --quiet openclaw-gateway 2>/dev/null; then
        echo "✅ Started!"
    else
        echo "❌ Failed. Check: journalctl --user -u openclaw-gateway -n 30"
    fi
fi

echo ""
echo "═══════════════════════════════════════════════"
echo "  Done! Send a Telegram message to test."
echo ""
echo "  Credentials saved to: $SECRETS_DIR"
echo "  These survive reboots and nixos-rebuild."
echo ""
echo "  Useful commands:"
echo "    systemctl --user status openclaw-gateway"
echo "    journalctl --user -u openclaw-gateway -f"
echo "    openclaw doctor"
echo "═══════════════════════════════════════════════"
