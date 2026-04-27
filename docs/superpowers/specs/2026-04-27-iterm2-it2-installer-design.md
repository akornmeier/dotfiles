# iTerm2 `it2` CLI Auto-Installer — Design

**Date:** 2026-04-27
**Status:** Approved (design); plan pending
**Owner:** Tony Kornmeier

## Problem

The `it2` CLI (iTerm2's Python-based control tool) is currently installed manually via `uv tool install it2`. The dotfiles repo already manages iTerm2 itself (Brewfile cask) but has no automation for the companion CLI. We want the `dot` workflow to install `it2` automatically when iTerm2 is present and keep it current on subsequent updates.

## Goals

1. `dot install` installs `it2` via `uv tool install it2` if iTerm2 is installed and `it2` is missing.
2. `dot update` installs `it2` if missing, and upgrades it if already installed.
3. If iTerm2 is not installed, the installer skips silently — never fails `dot install` or `dot update`.
4. The installer is extensible to other iTerm2-related uv tools via a single array.

## Non-Goals

- Generic uv-tool framework usable across unrelated topics. (YAGNI; today this is iTerm2-scoped.)
- Fixing the orphaned `claude/install.sh` wiring. Noted as a follow-up; out of scope here.
- Managing iTerm2 itself — that stays in the Brewfile.
- Pinning specific `it2` versions.

## Design

### File layout

```
iterm2/
└── install.sh          # new
```

This mirrors the existing topic convention (`claude/`, `fnm/`, `tmux/`, `zsh/`, `macos/`).

### Script contract

`iterm2/install.sh` is a sourced bash script (consistent with peers). It:

1. **Guards** on iTerm2 presence: `[ -d "/Applications/iTerm.app" ]`. If absent, prints `⏩ iTerm2 not installed, skipping it2 setup` and exits 0.
2. **Guards** on `uv` availability: `command -v uv`. If absent, prints `⚠️ uv not found — install via Brewfile` and exits 0. (Defensive — Brewfile guarantees it during `dot install`.)
3. Defines `UV_TOOLS=("it2")` — single source of truth, extensible by adding entries.
4. Iterates `UV_TOOLS`. For each tool:
   - Detect installed state via `uv tool list` (parsed for `^<tool> ` line prefix).
   - If missing: `uv tool install <tool>`.
   - If installed and `$DOT_MODE` = `update`: `uv tool upgrade <tool>`.
   - If installed and `$DOT_MODE` ≠ `update`: print `✓ <tool> already installed` and continue.
5. Each `uv tool install/upgrade` call uses `|| true` chaining (or equivalent) so a single tool failure doesn't abort the rest of `dot install`/`dot update`.

### Mode signaling

`bin/dot` exports `DOT_MODE=install` before sourcing the installer from `cmd_install`, and `DOT_MODE=update` before sourcing from `cmd_update`. The script reads `$DOT_MODE` to decide upgrade behavior. Default (unset) is treated as `install` semantics.

### Wiring into `bin/dot`

**`cmd_install`** — source `iterm2/install.sh` after the FNM block (which begins around line 276) and before the zsh installer (around line 353). This places it after `brew bundle install` (which provides iTerm2 and uv) and after FNM Node setup (no dependency, but matches the topic-installer flow).

**`cmd_update`** — source `iterm2/install.sh` after the `brew bundle check` self-heal block (which ends around line 431) and before the npm globals update block (around line 447). This is the first topic installer ever sourced from `cmd_update`; the convention being established is "topic installers are safe to run in update mode and read `$DOT_MODE` for branching."

### Output style

Match `claude/install.sh` conventions:

- Emoji-prefixed banner line at start (e.g., `🖥️  Setting up iTerm2 CLI tooling...`).
- Two-space indented status lines using `✓` (success), `⚠️` (warning), `⏩` (skip).
- Closing summary line only if at least one tool was acted on.

## Detection logic detail

```bash
# iTerm2 presence
if [ ! -d "/Applications/iTerm.app" ]; then
    echo "⏩ iTerm2 not installed, skipping it2 setup"
    exit 0
fi

# uv availability
if ! command -v uv &> /dev/null; then
    echo "⚠️  uv not found — install via Brewfile"
    exit 0
fi

# tool installed?
if uv tool list 2>/dev/null | grep -q "^${tool} "; then
    # installed
fi
```

The `uv tool list` output prefixes each tool name with `<name> v<version>` at the start of a line, so `^<tool> ` is a stable parse target.

## Error handling

| Condition | Behavior |
|---|---|
| iTerm2 missing | Skip silently with `⏩` line, exit 0 |
| `uv` missing | Warn with `⚠️` line, exit 0 |
| Single `uv tool install` fails (e.g., network) | Print warning, continue with next tool, don't abort `dot` |
| Single `uv tool upgrade` fails | Same as above |
| `uv tool list` parse error | Treat as "not installed" — install path will retry; failures are surfaced there |

## Documentation updates

`CLAUDE.md` gets a new subsection under "Topic-Based Organization" describing the `iterm2/` topic and the `UV_TOOLS` extension pattern. No README changes required.

## Test plan

1. **Fresh-state install** — uninstall `it2` (`uv tool uninstall it2`), run `dot install`, confirm `it2` is reinstalled and `it2 --version` works.
2. **Idempotent install** — run `dot install` again with `it2` already present, confirm `✓ it2 already installed` and no re-install.
3. **Upgrade on update** — run `dot update`, confirm either `✓ it2 already up to date` (if at latest) or upgrade output.
4. **Missing iTerm2** — temporarily rename `/Applications/iTerm.app` (or test on a machine without it), run `dot update`, confirm skip line and zero exit.
5. **Missing uv** — simulate by running script with `PATH` stripped of `/usr/local/bin` and `/opt/homebrew/bin`, confirm `⚠️ uv not found` warn-and-skip.

## Follow-ups (out of scope)

- `claude/install.sh` is currently defined but not sourced from `bin/dot` (`cmd_install` skips it; `cmd_update` doesn't source any topic installers). Wiring it in would benefit from the same `$DOT_MODE` convention introduced here. Track separately.
