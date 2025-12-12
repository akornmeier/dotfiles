# gsync Script Design

**Date:** 2025-12-12
**Status:** Approved

## Overview

Transform `gsync` from a simple alias into a standalone script that syncs with the remote, cleans up stale local branches, and optionally runs project build commands.

## Requirements

1. **Interactive prompts** for branches that can't be cleanly deleted (unmerged commits)
2. **Integrated into gsync** - single command for full sync workflow
3. **Auto-detect pnpm projects** - only run build commands when applicable
4. **Auto-detect default branch** - no hardcoded `main`/`master`

## Implementation

### Location

- **Script:** `bin/gsync` (executable, added to `$PATH`)
- **Remove:** `gsync` alias from `git/aliases.zsh` (line 21)

### Script Logic

1. **Fetch and prune** - `git fetch --prune`
2. **Detect default branch** - Query remote for HEAD branch
3. **Pull if on default branch** - Only pulls when on the default branch
4. **Clean stale branches:**
   - Find branches with `[gone]` upstream tracking
   - Skip current branch
   - Try safe delete (`-d`) first
   - Prompt for force delete (`-D`) on unmerged branches
5. **Project detection** - If `package.json` + `pnpm-lock.yaml` exist, run `pnpm i && pnpm build && pnpm test`

### Full Script

```sh
#!/bin/bash
set -e

echo "=== gsync: Syncing with remote ==="

# Fetch and prune stale remote-tracking branches
git fetch --prune

# Auto-detect default branch from remote
default_branch=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
current_branch=$(git branch --show-current)

if [[ "$current_branch" == "$default_branch" ]]; then
  git pull origin "$default_branch"
else
  echo "On branch '$current_branch', fetched '$default_branch' from origin"
fi

# Find and clean up local branches whose upstream is gone
gone_branches=$(git for-each-ref --format '%(refname:short) %(upstream:track)' refs/heads | \
  grep '\[gone\]' | awk '{print $1}' || true)

if [[ -n "$gone_branches" ]]; then
  echo ""
  echo "Local branches with deleted remotes:"

  for branch in $gone_branches; do
    if [[ "$branch" == "$current_branch" ]]; then
      echo "  ⚠ $branch (skipped - currently checked out)"
      continue
    fi

    if git branch -d "$branch" 2>/dev/null; then
      echo "  ✓ $branch (deleted)"
    else
      echo "  ✗ $branch has unmerged commits"
      read -p "    Force delete? [y/N] " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        git branch -D "$branch"
        echo "    ✓ Force deleted"
      else
        echo "    ⏭ Skipped"
      fi
    fi
  done
else
  echo "No stale local branches to clean up"
fi

# Auto-detect pnpm project and run build/test
if [[ -f "package.json" ]] && [[ -f "pnpm-lock.yaml" ]]; then
  echo ""
  echo "Detected pnpm project, running install/build/test..."
  pnpm i && pnpm build && pnpm test
fi

echo ""
echo "=== gsync complete ==="
```

## Migration

- Old behavior: `gsync` was an alias for `git pull origin main && pnpm i && pnpm build && pnpm test`
- New behavior: Smarter script with branch cleanup, auto-detection, and interactive prompts
- Breaking change: None (superset of old functionality)
