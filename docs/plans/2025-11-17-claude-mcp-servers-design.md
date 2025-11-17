# Claude MCP Servers Setup Design

**Date:** 2025-11-17
**Status:** Approved

## Overview

Add support for managing Claude Desktop MCP (Model Context Protocol) servers through the dotfiles system. The solution will create a new `claude/` topic that manages MCP server configurations and gracefully handles cases where Claude Desktop is not installed.

## Requirements

- Install and configure two MCP servers:
  - **serena**: Python-based server using `uvx` from git repository
  - **sequential-thinking**: npm-based server using `npx`
- Fail gracefully if Claude Desktop is not installed
- Follow existing dotfiles patterns and conventions
- Preserve existing user configurations
- Make it easy to add more MCP servers in the future

## Architecture

### Directory Structure

```
claude/
├── install.sh                           # Installation script
└── claude_desktop_config.json.template  # MCP server configuration
```

### Configuration File

Location: `~/Library/Application Support/Claude/claude_desktop_config.json`

The template will be a complete, valid JSON file:

```json
{
  "mcpServers": {
    "serena": {
      "command": "uvx",
      "args": [
        "--from",
        "git+https://github.com/oraios/serena",
        "serena",
        "start-mcp-server"
      ]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sequential-thinking"
      ]
    }
  }
}
```

**Why not `.symlink`?**
Claude's config location (`~/Library/Application Support/Claude/`) is non-standard (not directly in `$HOME`). Rather than extending the generic symlink system, the `install.sh` script handles this special case.

## Installation Script Behavior

The `claude/install.sh` script will:

1. **Check for Claude Desktop**
   - Look for `/Applications/Claude.app`
   - If not found: print "⏩ Claude not installed, skipping MCP setup" and exit 0
   - If found: continue with setup

2. **Create necessary directories**
   - Ensure `~/Library/Application Support/Claude/` exists

3. **Manage configuration symlink**
   - If symlink exists and points to our template: skip
   - If symlink exists but points elsewhere: update to our template
   - If regular file exists: warn and skip (preserve user config)
   - If nothing exists: create new symlink

4. **Report status**
   - Show success message when complete

## Integration with Existing System

### Dependencies (already in Brewfile)
- `brew 'uv'` - for Serena's uvx command
- `cask 'claude'` - Claude Desktop app
- Node.js via FNM - for npx command

### Dotfiles Integration
- `dot install` automatically runs `claude/install.sh`
- `dot update` doesn't need special handling
- No changes needed to existing scripts

### Adding More MCP Servers
1. Edit `claude/claude_desktop_config.json.template`
2. Run `./claude/install.sh` or `dot install`
3. Fully quit Claude Desktop (File → Exit)
4. Restart Claude Desktop

## User Workflow

```bash
# First time setup
dot install

# After adding new MCP servers to template
./claude/install.sh

# Manual verification
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

## Post-Installation

User must fully quit Claude Desktop (File → Exit, not just close window) and restart for MCP servers to become available.

## Error Handling

- **Claude not installed**: Graceful skip with informative message
- **Existing config file**: Preserve user's configuration, show warning
- **Missing directories**: Create automatically
- **Dependencies missing**: Rely on Brewfile to ensure uv and Node.js are installed

## Testing

To verify the setup:
1. Run `dot install`
2. Check for config symlink: `ls -la ~/Library/Application\ Support/Claude/`
3. Verify symlink target points to dotfiles template
4. Restart Claude Desktop
5. Look for hammer icon in Claude interface indicating MCP tools are loaded
