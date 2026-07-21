# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun
case ":$PATH:" in
  *":$HOME/.bun/bin:"*) ;;
  *) export PATH="$PATH:$HOME/.bun/bin" ;;
esac
# bun end
