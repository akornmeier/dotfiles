#!/bin/bash

# herdr installer
# Installs the herdr CLI (terminal workspace manager for AI coding agents)
# via the upstream curl installer, and self-updates it via `herdr update`.
# Sourced by bin/dot from cmd_install and cmd_update.
# Reads $DOT_MODE (install|update) to branch upgrade behavior.

echo ""
echo "🐂 Setting up herdr..."

# Default mode is install if not set
DOT_MODE="${DOT_MODE:-install}"

if command -v herdr &> /dev/null; then
  if [ "$DOT_MODE" = "update" ]; then
    echo "  🔄 Updating herdr..."
    herdr update 2>&1 | sed 's/^/    /'
    if [ "${PIPESTATUS[0]}" -eq 0 ]; then
      echo "  ✓ herdr update complete"
    else
      echo "  ⚠️  Failed to update herdr (continuing)"
    fi
  else
    echo "  ✓ herdr already installed"
  fi
else
  echo "  📦 Installing herdr..."
  curl -fsSL https://herdr.dev/install.sh | sh 2>&1 | sed 's/^/    /'
  # PIPESTATUS indices: [0]=curl, [1]=sh installer, [2]=sed
  installer_status="${PIPESTATUS[1]}"
  if [ "$installer_status" -eq 0 ] && [ -x "$HOME/.local/bin/herdr" ]; then
    echo "  ✓ herdr installed"
  else
    echo "  ⚠️  Failed to install herdr (continuing)"
  fi
fi

echo "  ✓ herdr setup complete"
