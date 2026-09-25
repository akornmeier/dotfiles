# pnpm
if [[ "$OSTYPE" == darwin* ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Some pnpm-installed packages (e.g. pi-coding-agent) put their shim in
# $PNPM_HOME/bin rather than $PNPM_HOME. `typeset -U PATH` keeps this
# idempotent across re-sources. Kept outside the `# pnpm` markers above so
# pnpm's own installer can rewrite that block without clobbering this.
export PATH="$PNPM_HOME/bin:$PATH"

# bun
case ":$PATH:" in
  *":$HOME/.bun/bin:"*) ;;
  *) export PATH="$PATH:$HOME/.bun/bin" ;;
esac
# bun end
