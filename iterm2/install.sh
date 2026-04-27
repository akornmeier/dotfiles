#!/bin/bash

# iTerm2 CLI tooling installer
# Installs uv-managed CLI tools that complement iTerm2 (e.g., it2).
# Sourced by bin/dot from cmd_install and cmd_update.
# Reads $DOT_MODE (install|update) to branch upgrade behavior.

echo ""
echo "🖥️  Setting up iTerm2 CLI tooling..."

# Guard 1: iTerm2 must be installed
if [ ! -d "/Applications/iTerm.app" ]; then
  echo "  ⏩ iTerm2 not installed, skipping it2 setup"
  return 0 2>/dev/null || exit 0
fi

# Guard 2: uv must be available (Brewfile guarantees it during dot install)
if ! command -v uv &> /dev/null; then
  echo "  ⚠️  uv not found — install via Brewfile"
  return 0 2>/dev/null || exit 0
fi

# Tools to install via `uv tool install`. Add entries to extend.
UV_TOOLS=("it2")

# Default mode is install if not set
DOT_MODE="${DOT_MODE:-install}"

for tool in "${UV_TOOLS[@]}"; do
  if uv tool list 2>/dev/null | grep -q "^${tool} "; then
    if [ "$DOT_MODE" = "update" ]; then
      echo "  🔄 Upgrading $tool..."
      if uv tool upgrade "$tool" 2>&1 | sed 's/^/    /'; then
        echo "  ✓ $tool upgrade complete"
      else
        echo "  ⚠️  Failed to upgrade $tool (continuing)"
      fi
    else
      echo "  ✓ $tool already installed"
    fi
  else
    echo "  📦 Installing $tool..."
    if uv tool install "$tool" 2>&1 | sed 's/^/    /'; then
      echo "  ✓ $tool installed"
    else
      echo "  ⚠️  Failed to install $tool (continuing)"
    fi
  fi
done

echo "  ✓ iTerm2 CLI tooling setup complete"
