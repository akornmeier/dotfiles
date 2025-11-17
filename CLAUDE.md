# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS dotfiles repository for managing development environment configuration. It uses a topic-based organization where each topic (zsh, git, macos, etc.) contains related configuration files and scripts.

## Core Commands

### Development Workflow

```sh
# Install dependencies and setup tooling
pnpm install

# Format code
pnpm format              # Format all files
pnpm format:check        # Check formatting without changing files

# Lint code
pnpm lint                # Run oxlint on all files
```

### Dotfiles Management

The `dot` command (in `bin/dot`) is the primary tool for managing dotfiles:

```sh
# Smart updates (default) - only updates what's needed
dot
dot update

# First-time setup
dot bootstrap

# Full installation
dot install

# Open dotfiles in editor
dot --edit
```

### Version Management

This project uses Changesets for version management:

```sh
pnpm changeset           # Create a new changeset
pnpm changeset:add       # Same as above
pnpm changeset:status    # View pending changesets
pnpm version             # Consume changesets and update version
pnpm release             # Create git tags for new versions
```

## Architecture

### Topic-Based Organization

The repository is organized by "topics" (directories), where each topic contains related configuration:

- **bin/**: Executables added to `$PATH` (e.g., `dot`, `e`, `set-defaults`)
- **zsh/**: Zsh configuration and Oh My Zsh setup
- **git/**: Git configuration and aliases
- **macos/**: macOS-specific settings and defaults
- **fnm/**: Fast Node Manager configuration
- **functions/**: Reusable shell functions
- **system/**: System-level configurations (keys, paths)

### File Naming Conventions

Files follow specific naming patterns with automatic behavior:

- **`*.symlink`**: Automatically symlinked to `$HOME` (e.g., `zshrc.symlink` → `~/.zshrc`)
- **`path.zsh`**: Loaded first, used for setting up `$PATH`
- **`*.zsh`**: Loaded into environment (aliases, config, completions)
- **`completion.zsh`**: Loaded last for autocomplete setup
- **`install.sh`**: Topic-specific installation scripts run during `dot install`

### The `dot` Script

The main orchestration script (`bin/dot`) handles three modes:

1. **`bootstrap`**: First-time setup
   - Sets up Git configuration (name/email)
   - Creates symlinks for dotfiles
   - Installs Homebrew if missing
   - Prompts to continue with full installation

2. **`install`**: Full installation
   - Updates symlinks
   - Installs all Brewfile packages
   - Runs topic installers (macos, fnm, zsh)
   - Applies macOS system defaults

3. **`update`** (default): Smart updates
   - Only updates changed symlinks
   - Updates Homebrew
   - Upgrades outdated packages only
   - Installs missing Brewfile packages
   - Removes Homebrew's Node (replaced by FNM)

### Symlink Management

Symlinks are created automatically from `*.symlink` files:
- Files are linked from topics into `$HOME`
- The script handles conflicts (skip, overwrite, backup)
- Only changed symlinks are updated during `dot update`

### Node.js Management

Uses FNM (Fast Node Manager) instead of nvm:
- Node binaries are symlinked to `/usr/local/bin` for system-wide access
- This enables GUI apps and MCP servers to use Node
- Homebrew's Node is automatically removed if detected
- Configured with `--use-on-cd`, `--version-file-strategy=recursive`, and `--corepack-enabled`

## Important Notes

### Brewfile

The Brewfile manages three types of installations:
1. Brew Taps - service level tasks
2. Brew formulas - CLI tools (git, gh, fnm, starship, etc.)
3. Casks - GUI applications (Chrome, Discord, Warp, Zoom, etc.)

**Note**: `mas` (Mac App Store CLI) entries are commented out due to compatibility issues with macOS Sequoia (15.x). These apps must be installed manually through the App Store.

### FNM Node Management

FNM is preferred over Homebrew's Node:
- Node.js LTS is installed via FNM
- Symlinks are created for global access (node, npm, npx, corepack)
- If any formula installs node as a dependency, it's removed by `fnm/install.sh` and `bin/dot`

### macOS Configuration

- `macos/install.sh`: Checks for macOS updates during installation
- `macos/set-defaults.sh`: Applies system preferences (requires sudo)
- Both scripts are run during `dot install`

### Scripts vs Bin

- **`script/`**: Legacy bootstrap and install scripts (now handled by `dot`)
- **`bin/`**: Executables added to `$PATH` for everyday use
  - `dot`: Main dotfiles management command
  - `e`: Quick editor launcher (opens in Zed)
  - `set-defaults`: Applies macOS system defaults

## Testing Changes

When modifying the dotfiles:

1. Test symlink changes: `dot update` (checks symlinks without full install)
2. Test full installation: `dot install` (runs all installers)
3. Test Brewfile changes: `brew bundle check` (verify) then `brew bundle install`
4. Format before committing: `pnpm format`
5. Create changeset for significant changes: `pnpm changeset`
