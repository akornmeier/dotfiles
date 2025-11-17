#!/bin/bash

echo "🤖 Setting up Claude MCP servers..."

# Check if Claude Desktop is installed
if [ ! -d "/Applications/Claude.app" ]; then
  echo "⏩ Claude not installed, skipping MCP setup"
  exit 0
fi

# Define paths
CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
CLAUDE_CONFIG_FILE="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"
TEMPLATE_FILE="$(cd "$(dirname "$0")" && pwd)/claude_desktop_config.json.template"

# Create config directory if it doesn't exist
mkdir -p "$CLAUDE_CONFIG_DIR"

# Create symlink (or update if changed)
if [ -L "$CLAUDE_CONFIG_FILE" ]; then
  # Existing symlink - check if it points to our template
  CURRENT_TARGET="$(readlink "$CLAUDE_CONFIG_FILE")"
  if [ "$CURRENT_TARGET" != "$TEMPLATE_FILE" ]; then
    ln -sf "$TEMPLATE_FILE" "$CLAUDE_CONFIG_FILE"
    echo "  ✓ Updated Claude config symlink"
  else
    echo "  ✓ Claude config already linked"
  fi
elif [ -e "$CLAUDE_CONFIG_FILE" ]; then
  # File exists but isn't our symlink - warn user
  echo "  ⚠️  Existing config found at $CLAUDE_CONFIG_FILE"
  echo "     Skipping to preserve your configuration"
  echo "     To use dotfiles config, backup and remove the existing file, then re-run this script"
else
  # No config exists - create symlink
  ln -s "$TEMPLATE_FILE" "$CLAUDE_CONFIG_FILE"
  echo "  ✓ Created Claude config symlink"
fi

echo ""
echo "✓ Claude MCP setup complete!"
echo ""
echo "  MCP servers configured:"
echo "    - serena (via uvx)"
echo "    - sequential-thinking (via npx)"
echo ""
echo "  ⚠️  Important: Fully quit Claude Desktop (File → Exit) and restart for changes to take effect"
echo ""
