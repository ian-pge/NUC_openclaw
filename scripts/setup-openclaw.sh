#!/usr/bin/env bash
# Run ONCE on the NUC after first nixos-rebuild to handle interactive steps.
set -euo pipefail

echo ""
echo "═══════════════════════════════════════════════"
echo "  OpenClaw Setup — One-Time Interactive Steps"
echo "═══════════════════════════════════════════════"

echo ""
echo "━━━ Step 1: Model Provider (ChatGPT OAuth) ━━━"
echo ""
echo "When prompted, choose:"
echo "  Provider → OpenAI"
echo "  Auth     → ChatGPT (OAuth)"
echo ""
echo "You'll get a URL to open in a browser."
echo "If NUC is headless, check which port openclaw is listening on:"
echo "ss -tlnp"
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
echo "━━━ Step 3: Verify ━━━"
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
echo "  Useful commands:"
echo "    systemctl --user status openclaw-gateway"
echo "    journalctl --user -u openclaw-gateway -f"
echo "    openclaw doctor"
echo "═══════════════════════════════════════════════"
