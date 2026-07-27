#!/bin/bash

# Installation of FNM happens in BREW.
#
# This script installs the latest LTS of Node.js via FNM and sets it as the
# default. We deliberately do NOT create /usr/local/bin/{node,npm,npx,corepack}
# symlinks any more — they pointed at FNM's "default" alias and beat FNM's
# per-shell shim (~/.local/state/fnm_multishells/PID/bin) on PATH, which made
# `node -v` ignore the project's .nvmrc and use the default alias instead.
#
# FNM env is initialised at the bottom of zsh/zshrc.symlink (AFTER all other
# PATH manipulation), so interactive shells always pick up the project version
# via --use-on-cd / --version-file-strategy=recursive.
#
# If a non-interactive context needs `node` on PATH (e.g. a GUI-spawned MCP
# server that doesn't run zsh startup), prefer one of:
#   1. Wrap the launcher in `zsh -lc '...'` so .zshrc runs and FNM resolves.
#   2. Point it at the FNM default explicitly:
#        $HOME/.local/share/fnm/aliases/default/bin/node
#   3. Add the FNM default bin to that launcher's PATH (e.g. a launchd plist).

echo "📦 Setting up FNM and Node.js..."

# Install latest LTS version of Node.js using FNM
echo "  Installing latest Node.js LTS version..."
eval "$(fnm env --use-on-cd --version-file-strategy=recursive --corepack-enabled --shell bash)"

# Install latest LTS and set as default
fnm install --lts
fnm default lts-latest

echo " Installed Node.js $(fnm current)"

# Best-effort cleanup of legacy symlinks from earlier versions of this script.
# Only removes them if they still point at the FNM default alias, so we don't
# clobber a user-installed node.
for legacy in node npm npx corepack; do
  link="/usr/local/bin/$legacy"
  if [[ -L "$link" ]] && [[ "$(readlink "$link")" == "$HOME/.local/share/fnm/aliases/default/"* ]]; then
    echo " Removing legacy FNM symlink $link"
    sudo rm -f "$link"
  fi
done

echo ""
echo "✓ FNM setup complete!"
echo "  node: $(node --version)"
echo "  npm: $(npm --version)"
echo "  npx: $(npx --version)"
echo "  corepack: $(corepack --version)"
