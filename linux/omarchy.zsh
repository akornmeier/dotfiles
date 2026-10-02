# Omarchy integration for zsh. Omarchy's shell setup targets bash, but its env,
# aliases and helper functions also run under zsh, so source them rather than
# copy them and keep picking up Omarchy's updates.
[[ "$OSTYPE" == linux* && -r /usr/share/omarchy/default/bash/env-bootstrap ]] || return

source /usr/share/omarchy/default/bash/env-bootstrap
source "$OMARCHY_PATH/default/bash/envs"
source "$OMARCHY_PATH/default/bash/aliases"
# Parse with aliases off: our `gd` alias (git/aliases.zsh) would otherwise
# expand inside Omarchy's `gd() {` and break parsing. The alias still wins at
# the prompt; Omarchy's worktree remover stays reachable as `\gd`.
() {
  setopt local_options no_aliases
  local f
  for f in "$OMARCHY_PATH"/default/bash/fns/*; do source "$f"; done
}

# Omarchy aliases `c` to opencode; keep `c` as our project jumper (functions/c).
unalias c 2>/dev/null

# Omarchy's `cd` alias is backed by zoxide.
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# gitconfig sets core.editor = vim, which Omarchy doesn't ship.
export GIT_EDITOR="$EDITOR"

# macOS clipboard commands, used by system/keys.zsh and functions/.
pbcopy() { wl-copy "$@" }
pbpaste() { wl-paste --no-newline "$@" }
