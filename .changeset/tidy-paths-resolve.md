---
'tk-dotfiles': patch
---

Fix `gsync` resolving to GNU `sync` from Homebrew coreutils instead of `bin/gsync`. `$DOTFILES/bin` now precedes `/usr/local/bin` in `$PATH`, and the relative `./bin` entry was removed so scripts in an arbitrary repo's `bin/` directory are no longer on `$PATH` by name.
