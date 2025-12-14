# tk-dotfiles

## 2.1.1

### Patch Changes

- 4d62d5f: improve gsync compatibility
- c9030f8: Transform gsync from alias to interactive branch cleanup script
- b41bff5: update 'gsync' command to clean branches no longer tracked on remote
- cfaa7f9: fix syntax issue in dot command
- e1a5e2f: Update Bash to latest in brewfile

## 2.1.0

### Minor Changes

- ea8a653: Add GitHub Actions for changeset enforcement and commitlint
  - Add changeset-check workflow to require changesets on PRs with code changes
  - Add commitlint workflow to enforce conventional commit messages
  - Configure commitlint with @commitlint/config-conventional

## 2.0.0

### Major Changes

- b3773b0: Unified dotfiles management with intelligent `dot` command

  This is a major refactor that consolidates all dotfiles management into a single, intelligent `dot` command with three subcommands:

  **New Commands:**
  - `dot bootstrap` - First-time setup (gitconfig, symlinks, Homebrew installation)
  - `dot install` - Full installation (packages, configs, macOS defaults)
  - `dot update` - Smart periodic updates (default - only updates what's needed)

  **Key Features:**
  - Intelligent updates that check before acting (no unnecessary operations)
  - Consistent, beautiful terminal output with color-coded sections
  - Only prompts for sudo when actually needed
  - Shows what changed vs. what was already up-to-date
  - Backward compatible with existing `script/bootstrap` and `script/install`

  **Breaking Changes:**
  - The `bin/dot` command now requires explicit subcommands or defaults to `update`
  - Running `dot` without arguments now runs smart updates instead of full installation
  - The keep-alive sudo background process is only started when needed

  **Migration:**
  - Existing workflows using `script/bootstrap` or `script/install` continue to work
  - Update any automation or documentation to use `dot bootstrap`, `dot install`, or `dot update`
  - For periodic updates, simply run `dot` or `dot update`

### Minor Changes

- 6a437e4: Add beautiful ASCII art banner to dot command

  Added a stunning gradient ASCII art banner that displays when running `dot` commands:

  **New Dependencies:**
  - `figlet` - ASCII art text generator
  - `gradient-string` - Beautiful gradient colors for terminal output
  - `@types/figlet` - TypeScript types for figlet

  **Implementation:**
  - Created `bin/lib/banner.mjs` - Node.js script that generates gradient ASCII art
  - Uses "ANSI Shadow" font for bold, clear text
  - Applies "cyber" color palette (cyan/blue gradient)
  - Gracefully falls back to plain text if Node.js is unavailable
  - Integrated into all main commands: `bootstrap`, `install`, and `update`

  **Visual Enhancement:**
  The banner adds a professional, eye-catching header to the dot command output, making it immediately clear when the dotfiles management system is running. The gradient colors match the modern, developer-focused aesthetic of the project.

- 91634a6: Add local code formatting and linting tools

  Added oxlint and prettier as local dev dependencies for maintaining code quality in the dotfiles project:

  **New Dev Dependencies:**
  - `oxlint@^0.13.0` - Fast, minimal JavaScript/TypeScript linter from Oxc project
  - `prettier@^3.4.2` - Opinionated code formatter

  **Configuration Files:**
  - `.prettierrc` - Prettier configuration with sensible defaults (single quotes, no semis, 100 char width)
  - `.prettierignore` - Excludes node_modules, build outputs, and system files
  - `oxlint.json` - Oxlint configuration with basic rules

  **New Scripts:**
  - `pnpm format` - Format all files with prettier
  - `pnpm format:check` - Check if files are formatted correctly
  - `pnpm lint` - Run oxlint on the project

  **Use Cases:**
  - Maintain consistent formatting across shell scripts, JSON, YAML, and Markdown
  - Catch common issues in JavaScript/JSON files
  - Ensure code quality before commits

- b3773b0: Add quick install script for fresh machines

  Added a convenient one-liner installation script that makes it easy to bootstrap dotfiles on a fresh macOS machine:

  ```sh
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/akornmeier/dotfiles/main/install.sh)"
  ```

  **Features:**
  - Automatically clones the dotfiles repository
  - Detects if dotfiles already exist and offers to update
  - Checks for Git installation and provides helpful guidance
  - Runs `dot bootstrap` to set up everything
  - Intelligent handling of existing installations (offers update via `dot update`)

  **Documentation:**
  - Updated README with "Quick Install" section at the top
  - Reorganized Getting Started to show the easiest method first
  - Moved Prerequisites to a more logical position
