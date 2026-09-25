# Uses git's autocompletion for inner commands. Assumes an install of git's
# zsh `_git` completion script at $completion below (this is where Homebrew
# installs it).
(( $+commands[brew] )) || return
completion="$(brew --prefix)/share/zsh/site-functions/_git"

if test -f "$completion"; then
  # Enable completion system if not already enabled
  autoload -Uz compinit
  compinit -i
fi