#!/bin/bash

echo "🤖 Setting up Claude MCP servers..."

# Check if Claude Desktop or Claude Code is installed
CLAUDE_DESKTOP_INSTALLED=false
CLAUDE_CODE_INSTALLED=false

if [ -d "/Applications/Claude.app" ]; then
  CLAUDE_DESKTOP_INSTALLED=true
fi

if command -v claude &> /dev/null; then
  CLAUDE_CODE_INSTALLED=true
fi

if [ "$CLAUDE_DESKTOP_INSTALLED" = false ] && [ "$CLAUDE_CODE_INSTALLED" = false ]; then
  echo "⏩ Neither Claude Desktop nor Claude Code installed, skipping MCP setup"
  exit 0
fi

# =============================================================================
# Claude Desktop Configuration
# =============================================================================

if [ "$CLAUDE_DESKTOP_INSTALLED" = true ]; then
  echo ""
  echo "📱 Configuring Claude Desktop..."

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
      echo "  ✓ Updated Claude Desktop config symlink"
    else
      echo "  ✓ Claude Desktop config already linked"
    fi
  elif [ -e "$CLAUDE_CONFIG_FILE" ]; then
    # File exists but isn't our symlink - warn user
    echo "  ⚠️  Existing config found at $CLAUDE_CONFIG_FILE"
    echo "     Skipping to preserve your configuration"
    echo "     To use dotfiles config, backup and remove the existing file, then re-run this script"
  else
    # No config exists - create symlink
    ln -s "$TEMPLATE_FILE" "$CLAUDE_CONFIG_FILE"
    echo "  ✓ Created Claude Desktop config symlink"
  fi

  echo "  ⚠️  Important: Fully quit Claude Desktop (File → Exit) and restart for changes to take effect"
fi

# =============================================================================
# Claude Code Configuration
# =============================================================================

if [ "$CLAUDE_CODE_INSTALLED" = true ]; then
  echo ""
  echo "💻 Configuring Claude Code..."

  # Add sequential-thinking MCP server
  if claude mcp list 2>/dev/null | grep -q "sequential-thinking"; then
    echo "  ✓ sequential-thinking already configured"
  else
    claude mcp add --scope user --transport stdio sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking 2>/dev/null
    if [ $? -eq 0 ]; then
      echo "  ✓ Added sequential-thinking MCP server"
    else
      echo "  ⚠️  Failed to add sequential-thinking (may already exist)"
    fi
  fi

  # Add serena MCP server
  if claude mcp list 2>/dev/null | grep -q "serena"; then
    echo "  ✓ serena already configured"
  else
    claude mcp add --scope user --transport stdio serena -- /opt/homebrew/bin/uvx --from git+https://github.com/oraios/serena serena start-mcp-server 2>/dev/null
    if [ $? -eq 0 ]; then
      echo "  ✓ Added serena MCP server"
    else
      echo "  ⚠️  Failed to add serena (may already exist)"
    fi
  fi

  echo "  💡 Tip: Use '/mcp' in Claude Code to authenticate MCP servers"
fi

# =============================================================================
# Summary
# =============================================================================

# Only show summary if at least one application was configured
if [ "$CLAUDE_DESKTOP_INSTALLED" = true ] || [ "$CLAUDE_CODE_INSTALLED" = true ]; then
  echo ""
  echo "✓ Claude MCP setup complete!"
  echo ""
  echo "  MCP servers configured:"
  echo "    - sequential-thinking (via npx)"
  echo "    - serena (via uvx)"
  echo ""
fi
