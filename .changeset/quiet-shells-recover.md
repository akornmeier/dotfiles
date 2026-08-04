---
'tk-dotfiles': patch
---

Keep running shells working when Homebrew upgrades `zsh-autocomplete`. The plugin pins its `~autocomplete` named directory to a versioned Cellar path at load time, so `brew upgrade` deletes that path out from under already-open shells and the deferred autoload of `z-async` fails on every line redraw (`.autocomplete:async:complete:61: z-async: function definition file not found`). A `precmd` hook now notices the dead directory and repoints `fpath` at `$HOMEBREW_PREFIX/share/zsh-autocomplete`, a stable directory of symlinks rather than a versioned one, so a repaired shell is also immune to later upgrades.
