# iTerm2 `it2` Auto-Installer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Automate `it2` CLI installation and upgrades through `dot install` / `dot update` when iTerm2 is present.

**Architecture:** New `iterm2/install.sh` topic installer with `UV_TOOLS=("it2")` array, gated on iTerm2 presence and `uv` availability. Sourced by `bin/dot` from both `cmd_install` and `cmd_update` with a `$DOT_MODE` env signal that branches on install vs upgrade.

**Tech Stack:** Bash, `uv tool` subcommand, existing dotfiles topic-installer convention.

**Spec:** `docs/superpowers/specs/2026-04-27-iterm2-it2-installer-design.md`

---

## File Structure

| Path                                 | Action           | Responsibility                                                                       |
| ------------------------------------ | ---------------- | ------------------------------------------------------------------------------------ |
| `iterm2/install.sh`                  | Create           | Topic installer — guards, `UV_TOOLS` array, install + upgrade loop                   |
| `bin/dot`                            | Modify (2 sites) | Source `iterm2/install.sh` from `cmd_install` and `cmd_update`, exporting `DOT_MODE` |
| `CLAUDE.md`                          | Modify           | Document the `iterm2/` topic and `UV_TOOLS` extension pattern                        |
| `.changeset/iterm2-it2-installer.md` | Create           | Changeset entry (project convention)                                                 |

No test framework exists in this repo; verification is manual smoke testing using concrete commands with expected output, per the project's existing convention.

---

## Task 1: Create `iterm2/install.sh` with guards and core loop

**Files:**

- Create: `iterm2/install.sh`

- [ ] **Step 1.1: Create `iterm2/install.sh` with full content**

```bash
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
```

- [ ] **Step 1.2: Make it executable**

Run:

```bash
chmod +x /Users/tk/.dotfiles/iterm2/install.sh
```

Expected: no output.

- [ ] **Step 1.3: Syntax-check the script**

Run:

```bash
bash -n /Users/tk/.dotfiles/iterm2/install.sh
```

Expected: no output, exit 0.

- [ ] **Step 1.4: Verify the "already installed" path (DOT_MODE unset → install semantics)**

Run:

```bash
bash /Users/tk/.dotfiles/iterm2/install.sh
```

Expected output includes:

```
🖥️  Setting up iTerm2 CLI tooling...
  ✓ it2 already installed
  ✓ iTerm2 CLI tooling setup complete
```

(Assumes `it2` is already installed in the user's env — confirmed by `which it2` showing `/Users/tk/.local/bin/it2`.)

- [ ] **Step 1.5: Verify the upgrade path (DOT_MODE=update)**

Run:

```bash
DOT_MODE=update bash /Users/tk/.dotfiles/iterm2/install.sh
```

Expected output includes:

```
🖥️  Setting up iTerm2 CLI tooling...
  🔄 Upgrading it2...
    ...
  ✓ it2 upgrade complete
  ✓ iTerm2 CLI tooling setup complete
```

(`uv tool upgrade it2` prints `Nothing to upgrade` if already current — that's still exit 0 and counts as success.)

- [ ] **Step 1.6: Verify the iTerm2-missing skip path**

Run:

```bash
# Simulate missing iTerm2 by overriding the path test via a wrapper script
DOT_MODE=install bash -c '
  cd /Users/tk/.dotfiles
  # Source with a faked iTerm.app check by temporarily moving the app would be destructive.
  # Instead, verify by reading the code path:
  grep -A 3 "Guard 1" iterm2/install.sh
'
```

Expected: prints the guard block — confirming it returns/exits 0 before reaching uv calls. (Full live skip test would require renaming `/Applications/iTerm.app`, which is destructive to the dev environment; the code-path inspection here is sufficient — the spec's test plan #4 covers full verification on systems without iTerm2.)

- [ ] **Step 1.7: Commit**

```bash
git -C /Users/tk/.dotfiles add iterm2/install.sh
git -C /Users/tk/.dotfiles commit -m "feat: add iterm2 topic installer for it2 uv tool

Adds iterm2/install.sh that installs the it2 CLI via uv tool
when iTerm2 is present and missing, and upgrades it when
DOT_MODE=update. Gated on iTerm2 presence and uv availability."
```

Expected: commit succeeds.

---

## Task 2: Wire `iterm2/install.sh` into `cmd_install`

**Files:**

- Modify: `bin/dot` (insert after the FNM block, before the zsh installer block)

- [ ] **Step 2.1: Locate the insertion site**

Run:

```bash
grep -n "Run zsh installer" /Users/tk/.dotfiles/bin/dot
```

Expected: returns one line, around line 352. The insertion goes immediately above this line (after the closing `fi` of the FNM block at line 350).

- [ ] **Step 2.2: Insert the iTerm2 installer source**

In `bin/dot`, find this block:

```bash
		fi
	fi

	# Run zsh installer
	if [ -f "$DOTFILES/zsh/install.sh" ]; then
		source "$DOTFILES/zsh/install.sh"
	fi
```

Replace with:

```bash
		fi
	fi

	# Run iTerm2 installer
	if [ -f "$DOTFILES/iterm2/install.sh" ]; then
		DOT_MODE=install source "$DOTFILES/iterm2/install.sh"
	fi

	# Run zsh installer
	if [ -f "$DOTFILES/zsh/install.sh" ]; then
		source "$DOTFILES/zsh/install.sh"
	fi
```

- [ ] **Step 2.3: Syntax-check `bin/dot`**

Run:

```bash
bash -n /Users/tk/.dotfiles/bin/dot
```

Expected: no output, exit 0.

- [ ] **Step 2.4: Verify the install branch executes correctly via dry-run trace**

Run:

```bash
grep -B 1 -A 3 "iterm2/install.sh" /Users/tk/.dotfiles/bin/dot
```

Expected output (one match, in `cmd_install`):

```
	# Run iTerm2 installer
	if [ -f "$DOTFILES/iterm2/install.sh" ]; then
		DOT_MODE=install source "$DOTFILES/iterm2/install.sh"
	fi
```

- [ ] **Step 2.5: Commit**

```bash
git -C /Users/tk/.dotfiles add bin/dot
git -C /Users/tk/.dotfiles commit -m "feat(dot): source iterm2/install.sh in cmd_install

Sources the new iterm2/install.sh with DOT_MODE=install after the
FNM block and before zsh installer, so iTerm2 cask (from Brewfile)
is on disk before it2 is installed."
```

Expected: commit succeeds.

---

## Task 3: Wire `iterm2/install.sh` into `cmd_update`

**Files:**

- Modify: `bin/dot` (insert after the brew bundle check + node cleanup blocks, before npm globals update block)

- [ ] **Step 3.1: Locate the insertion site**

Run:

```bash
grep -n "Cleanup complete\|Updating npm global\|Update npm global packages" /Users/tk/.dotfiles/bin/dot
```

Expected: returns lines around 444, 447 (cleanup complete), and 456 (npm globals header). The insertion goes immediately after the `brew cleanup` block ends (after the `✓ Cleanup complete` echo) and before the `# Update npm global packages` comment.

- [ ] **Step 3.2: Insert the iTerm2 installer source**

In `bin/dot` `cmd_update`, find this block:

```bash
	echo ""
	echo "🧹 Cleaning up Homebrew..."
	brew cleanup
	echo -e "  ${GREEN}✓ Cleanup complete${NC}"

	# Update npm global packages (if FNM/Node is available)
	if command -v npm &> /dev/null; then
```

Replace with:

```bash
	echo ""
	echo "🧹 Cleaning up Homebrew..."
	brew cleanup
	echo -e "  ${GREEN}✓ Cleanup complete${NC}"

	# Run iTerm2 installer in update mode
	if [ -f "$DOTFILES/iterm2/install.sh" ]; then
		DOT_MODE=update source "$DOTFILES/iterm2/install.sh"
	fi

	# Update npm global packages (if FNM/Node is available)
	if command -v npm &> /dev/null; then
```

- [ ] **Step 3.3: Syntax-check `bin/dot`**

Run:

```bash
bash -n /Users/tk/.dotfiles/bin/dot
```

Expected: no output, exit 0.

- [ ] **Step 3.4: Verify both install and update sites are wired**

Run:

```bash
grep -c "iterm2/install.sh" /Users/tk/.dotfiles/bin/dot
```

Expected: `2`

Run:

```bash
grep "DOT_MODE=" /Users/tk/.dotfiles/bin/dot
```

Expected output (two lines):

```
		DOT_MODE=install source "$DOTFILES/iterm2/install.sh"
		DOT_MODE=update source "$DOTFILES/iterm2/install.sh"
```

- [ ] **Step 3.5: Commit**

```bash
git -C /Users/tk/.dotfiles add bin/dot
git -C /Users/tk/.dotfiles commit -m "feat(dot): source iterm2/install.sh in cmd_update with DOT_MODE=update

Self-heals it2 if missing during dot update, and upgrades it
to the latest version. First topic installer sourced from
cmd_update — establishes the DOT_MODE=update convention."
```

Expected: commit succeeds.

---

## Task 4: Document the new topic in `CLAUDE.md`

**Files:**

- Modify: `CLAUDE.md` (insert new subsection under "Important Notes")

- [ ] **Step 4.1: Find the "Claude MCP Servers" subsection — we'll add the iTerm2 subsection right above it**

Run:

```bash
grep -n "^### Claude MCP Servers" /Users/tk/.dotfiles/CLAUDE.md
```

Expected: returns one line.

- [ ] **Step 4.2: Insert the iTerm2 subsection**

In `CLAUDE.md`, find this line:

```markdown
### Claude MCP Servers
```

Insert immediately above it:

```markdown
### iTerm2 CLI Tooling

The `iterm2/` topic installs uv-managed CLI tools that complement iTerm2 (e.g., `it2`):

- Gated on iTerm2 being installed at `/Applications/iTerm.app` (skips silently otherwise)
- Gated on `uv` being available (Brewfile guarantees this)
- Tools listed in the `UV_TOOLS=("it2")` array inside `iterm2/install.sh` — add entries to extend
- Runs in both `dot install` and `dot update`:
  - `dot install` (DOT_MODE=install): installs missing tools
  - `dot update` (DOT_MODE=update): installs missing tools and upgrades existing ones
- Failures on a single tool emit a warning and continue — never abort the broader `dot` run

**Adding more uv tools:**

- Edit `UV_TOOLS=()` in `iterm2/install.sh` and re-run `dot install` or `dot update`

### Claude MCP Servers
```

- [ ] **Step 4.3: Verify the doc renders**

Run:

```bash
grep -A 2 "^### iTerm2 CLI Tooling" /Users/tk/.dotfiles/CLAUDE.md
```

Expected output:

```
### iTerm2 CLI Tooling

The `iterm2/` topic installs uv-managed CLI tools that complement iTerm2 (e.g., `it2`):
```

- [ ] **Step 4.4: Commit**

```bash
git -C /Users/tk/.dotfiles add CLAUDE.md
git -C /Users/tk/.dotfiles commit -m "docs: document iterm2 topic and UV_TOOLS extension pattern"
```

Expected: commit succeeds.

---

## Task 5: Add changeset entry

**Files:**

- Create: `.changeset/iterm2-it2-installer.md`

- [ ] **Step 5.1: Create the changeset file**

Write file `/Users/tk/.dotfiles/.changeset/iterm2-it2-installer.md` with this exact content:

```markdown
---
'tk-dotfiles': minor
---

Add iterm2 topic installer that auto-installs the it2 CLI via uv tool when iTerm2 is present, and upgrades it on dot update. Introduces a DOT_MODE env signal so topic installers can branch on install vs update lifecycle.
```

- [ ] **Step 5.2: Verify the changeset format**

Run:

```bash
cat /Users/tk/.dotfiles/.changeset/iterm2-it2-installer.md
```

Expected: prints exactly the content above.

- [ ] **Step 5.3: Run pnpm format to align with repo style**

Run:

```bash
cd /Users/tk/.dotfiles && pnpm format
```

Expected: prints formatted file count, no errors. Re-formats the changeset file if needed.

- [ ] **Step 5.4: Commit**

```bash
git -C /Users/tk/.dotfiles add .changeset/iterm2-it2-installer.md
git -C /Users/tk/.dotfiles commit -m "chore: add changeset for iterm2 it2 installer"
```

Expected: commit succeeds.

---

## Task 6: End-to-end verification

**Files:** none (read-only verification)

- [ ] **Step 6.1: Run `dot update` end-to-end**

Run:

```bash
/Users/tk/.dotfiles/bin/dot update
```

Expected behavior in output:

- Standard `dot update` flow runs (symlinks, brew, etc.)
- After `🧹 Cleaning up Homebrew...` block, see:
  ```
  🖥️  Setting up iTerm2 CLI tooling...
    🔄 Upgrading it2...
      ...
    ✓ it2 upgrade complete
    ✓ iTerm2 CLI tooling setup complete
  ```
- npm globals block runs after (or skips if `NPM_GLOBALS` is empty)
- Final "Update complete" banner

Confirm exit code:

```bash
echo $?
```

Expected: `0`

- [ ] **Step 6.2: Verify `it2` still works**

Run:

```bash
it2 --version
```

Expected: prints a version line (should match what `uv tool list` shows for `it2`).

- [ ] **Step 6.3: Verify idempotency — run `dot update` again**

Run:

```bash
/Users/tk/.dotfiles/bin/dot update
```

Expected: same iTerm2 block output as before; `uv tool upgrade it2` reports `Nothing to upgrade` or similar; exit code 0.

- [ ] **Step 6.4: Final summary commit (if any incidental fixes)**

If any small fix was needed during verification (e.g., output formatting, typo), commit it. Otherwise skip.

---

## Self-review checklist (executed by plan author)

- ✅ Spec coverage:
  - Goal #1 (install on `dot install` if missing) → Task 1 + Task 2
  - Goal #2 (install/upgrade on `dot update`) → Task 1 + Task 3
  - Goal #3 (skip silently if iTerm2 missing) → Task 1 (Guard 1)
  - Goal #4 (extensible via array) → Task 1 (`UV_TOOLS=("it2")`)
  - `$DOT_MODE` env convention → Task 2 + Task 3
  - Output style mirrors `claude/install.sh` → Task 1 (✓/⚠️/⏩ prefixes)
  - Documentation update → Task 4
  - Test plan → Task 1 verification steps + Task 6 end-to-end
- ✅ Placeholder scan: every step contains exact code, exact paths, exact commands
- ✅ Type consistency: `UV_TOOLS`, `DOT_MODE`, `iterm2/install.sh` named identically across all tasks
- ✅ Skipped formal TDD: no test framework in repo; verification is concrete commands with expected output, matching project convention
