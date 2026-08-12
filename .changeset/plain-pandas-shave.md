---
'tk-dotfiles': patch
---

Add `$PNPM_HOME/bin` to `$PATH` so shims from pnpm global installs resolve, and drop the `pi-coding-agent` formula from the Brewfile. `pi-coding-agent` is now installed via pnpm rather than Homebrew; the install itself stays manual.
