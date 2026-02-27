#!/usr/bin/env bash
# Pull latest from GitHub and rebuild. Run on NUC after pushing changes.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "📥 Pulling..."
git pull --ff-only

echo "🔨 Rebuilding NixOS (includes Home Manager)..."
sudo nixos-rebuild switch --flake .#nuc

echo "✅ Done."
systemctl --user status openclaw-gateway --no-pager || true
