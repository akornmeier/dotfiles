#!/bin/bash
#
# Linux (Omarchy) steps for bin/dot, which sources this file on Linux.
# Provides the same interface as macos/dot.sh.
#
# System upgrades are left to `omarchy-update`; this only installs what is
# missing from linux/packages and keeps the mise tools current.

# gh comes from mise (linux/mise.toml); without it, fall back to git's cache.
if command -v gh &> /dev/null; then
	os_git_credential='!gh auth git-credential'
else
	os_git_credential='cache'
fi

# Omarchy ships its own ~/.config/tmux/tmux.conf; point it at ours too so the
# result doesn't depend on which of the two paths tmux picks.
os_links=(
	"$DOTFILES/tmux/tmux.conf.symlink" "$HOME/.config/tmux/tmux.conf"
	"$DOTFILES/linux/mise.toml" "$HOME/.config/mise/config.toml"
)

os_bootstrap() {
	command -v yay &> /dev/null || fail "yay not found — this Linux setup expects Omarchy (Arch + yay)"
}

os_install() {
	linux_install_packages
	echo ""
	echo "🔧 Installing mise tools..."
	mise install --yes
	echo -e "  ${GREEN}✓ mise tools ready${NC}"
}

os_configure() {
	local zsh
	zsh="$(command -v zsh)"
	if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$zsh" ]; then
		echo ""
		echo "🐚 Switching login shell to zsh..."
		chsh -s "$zsh" && echo -e "  ${GREEN}✓ Login shell is zsh (log out to apply)${NC}"
	fi
}

os_cleanup() {
	fail "dot cleanup is macOS only"
}

os_update() {
	linux_install_packages
	echo ""
	echo "🔧 Upgrading mise tools..."
	mise upgrade --yes
	echo -e "  ${GREEN}✓ mise tools ready${NC}"
}

linux_install_packages() {
	echo ""
	echo "============================================================"
	echo -e "${BLUE}🐧 Checking linux/packages...${NC}"
	echo "============================================================"

	local packages missing
	mapfile -t packages < <(sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$DOTFILES/linux/packages")
	mapfile -t missing < <(pacman -T "${packages[@]}")
	if [ ${#missing[@]} -gt 0 ]; then
		echo "  Installing: ${missing[*]}"
		# No -y: syncing without a full upgrade is a partial upgrade, which Arch
		# doesn't support. A stale database 404s here; omarchy-update fixes it.
		yay -S --needed --noconfirm "${missing[@]}" ||
			fail "Package install failed. If mirrors returned 404, run 'omarchy-update', then 'dot install'."
		echo -e "  ${GREEN}✓ Packages installed${NC}"
	else
		echo -e "  ${GREEN}✓ All packages are installed${NC}"
	fi
}
