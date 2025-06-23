#!/bin/bash

# Installation of FNM happens in BREW
# This script is used to create or update the symlinks for Node.js, npm, npx, and corepack
# These symlink allow Claude MCP commands to use the Node.js version managed by FNM (Fast Node Manager)

# Create or update the symlink to the current fnm Node version
sudo ln -sf $HOME/.local/share/fnm/aliases/default/bin/node /usr/local/bin/node
sudo ln -sf $HOME/.local/share/fnm/aliases/default/bin/npm /usr/local/bin/npm
sudo ln -sf $HOME/.local/share/fnm/aliases/default/bin/npx /usr/local/bin/npx
sudo ln -sf $HOME/.local/share/fnm/aliases/default/bin/corepack /usr/local/bin/corepack

echo "Node.js symlinks updated"
echo "node: $(node --version)"
echo "npm: $(npm --version)"
echo "npx: $(npx --version)"
echo "corepack: $(corepack --version)"
