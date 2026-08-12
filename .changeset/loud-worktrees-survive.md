---
'tk-dotfiles': patch
---

Stop `gsync` from prompting to delete branches that are checked out in a git worktree. `git branch -d/-D` refuses those with `error: cannot delete branch 'x' used by worktree at '...'`, so the prompt could only ever fail — and under `set -e` that failure aborted the rest of the run (pnpm install/build/test never happened). `gsync` now reads `git worktree list --porcelain` and skips such branches with the worktree path in the message.
