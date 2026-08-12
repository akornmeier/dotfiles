# tk-dotfiles

## 2.4.1

### Patch Changes

- c17d32a: Fix release CI so versions are actually tagged and published as GitHub Releases: the Release workflow now runs `changeset tag` as its publish step (with full git history so existing tags are detected), and changesets is configured to tag this private package.

## 2.4.0

### Minor Changes

- 97dc6fc: Add herdr topic installer that auto-installs the herdr CLI via the upstream curl installer when missing, and self-updates it via the built-in `herdr update` command on dot update.
- 88ebe11: Add iterm2 and bun to Brewfile, expand global gitignore, bump pnpm to 10.33.0, fix zsh-completions fpath, and add --verbose to cldyo alias. CI workflows now read pnpm version from packageManager field.
- 8f2dad0: Add iterm2 topic installer that auto-installs the it2 CLI via uv tool when iTerm2 is present, and upgrades it on dot update. Introduces a DOT_MODE env signal so topic installers can branch on install vs update lifecycle.
- c2a5a22: Add cmux and rtk to homebrew

### Patch Changes

- d1912fc: Stop `dot` from uninstalling Homebrew's `node`, which broke every formula that depends on it. `brew uninstall --ignore-dependencies node` ran in `cmd_install`, `cmd_update`, and `fnm/install.sh`, so each `dot` run left `pi-coding-agent` and `mongosh` with a dangling `/opt/homebrew/opt/node/bin/node` shebang (`bad interpreter`). The removal was already obsolete: FNM's per-shell shim outranks `/opt/homebrew/bin` on `$PATH`, so Homebrew's node cannot shadow it. Also drops the `/usr/local/bin/{node,npm,npx,corepack}` symlink block from `cmd_install`, which recreated the exact symlinks `fnm/install.sh` deletes as legacy moments later in the same run.
- a79b486: Stop `gsync` from prompting to delete branches that are checked out in a git worktree. `git branch -d/-D` refuses those with `error: cannot delete branch 'x' used by worktree at '...'`, so the prompt could only ever fail — and under `set -e` that failure aborted the rest of the run (pnpm install/build/test never happened). `gsync` now reads `git worktree list --porcelain` and skips such branches with the worktree path in the message.
- 3aa9c4b: chore: update brewfile
- 9700ebc: Add `$PNPM_HOME/bin` to `$PATH` so shims from pnpm global installs resolve, and drop the `pi-coding-agent` formula from the Brewfile. `pi-coding-agent` is now installed via pnpm rather than Homebrew; the install itself stays manual.
- f0ed6bb: Keep running shells working when Homebrew upgrades `zsh-autocomplete`. The plugin pins its `~autocomplete` named directory to a versioned Cellar path at load time, so `brew upgrade` deletes that path out from under already-open shells and the deferred autoload of `z-async` fails on every line redraw (`.autocomplete:async:complete:61: z-async: function definition file not found`). A `precmd` hook now notices the dead directory and repoints `fpath` at `$HOMEBREW_PREFIX/share/zsh-autocomplete`, a stable directory of symlinks rather than a versioned one, so a repaired shell is also immune to later upgrades.
- 7ef62aa: Fix `gsync` resolving to GNU `sync` from Homebrew coreutils instead of `bin/gsync`. `$DOTFILES/bin` now precedes `/usr/local/bin` in `$PATH`, and the relative `./bin` entry was removed so scripts in an arbitrary repo's `bin/` directory are no longer on `$PATH` by name.

## 2.3.0

### Minor Changes

- b586a18: Added new brew recipes for bun and just

## 2.2.0

### Minor Changes

- 8bff98f: add tmux configuration and installation scripts

### Patch Changes

- 0e970c6: Remove tdd-guard from NPM_GLOBALS arrays in both install and update
- ba35ff3: Update brewfile and a claude code alias
- 8b099b8: add tmux visual plugins for claude orchestration

## 2.1.2

### Patch Changes

- dd22971: switch tdd-guard from Homebrew to npm global

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
