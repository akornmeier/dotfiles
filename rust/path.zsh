# Homebrew's `rust` formula only puts rustc/cargo in $HOMEBREW_PREFIX/bin.
# Anything installed with `cargo install` lands in $CARGO_HOME/bin (~/.cargo/bin
# by default), which is not on $PATH otherwise. `typeset -U PATH` in
# zsh/zshrc.symlink keeps this idempotent across re-sources.
export PATH="$HOME/.cargo/bin:$PATH"
