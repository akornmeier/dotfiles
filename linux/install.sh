#!/bin/bash
#
# Linux (Omarchy) installer
# Sourced by bin/dot from cmd_install and cmd_update, so link_file and the
# color variables are available. Reads $DOT_MODE (install|update).
#
# System upgrades are left to `omarchy-update`; this only installs what is
# missing from linux/packages and links the XDG configs.

DOT_MODE="${DOT_MODE:-install}"

echo ""
echo "============================================================"
echo -e "${BLUE}🐧 Setting up Linux (Omarchy)...${NC}"
echo "============================================================"

# Packages
echo ""
echo "📦 Checking linux/packages..."
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

# XDG configs that don't fit the *.symlink -> ~/.name convention.
# Omarchy ships its own ~/.config/tmux/tmux.conf; point it at ours too so the
# result doesn't depend on which of the two paths tmux picks.
echo ""
echo "🔗 Linking XDG configs..."
local overwrite_all=false backup_all=false skip_all=false
link_xdg () {
	local src="$DOTFILES/$1" dst="$HOME/.config/$2"
	mkdir -p "$(dirname "$dst")"
	if [ -L "$dst" ] && [ "$(readlink "$dst")" == "$src" ]; then
		echo -e "  ${GREEN}✓ $dst already linked${NC}"
	else
		link_file "$src" "$dst"
	fi
}
link_xdg tmux/tmux.conf.symlink tmux/tmux.conf
link_xdg linux/mise.toml mise/config.toml

# Runtimes
echo ""
echo "🔧 Installing mise tools..."
if [ "$DOT_MODE" = "update" ]; then
	mise upgrade --yes
else
	mise install --yes
fi
echo -e "  ${GREEN}✓ mise tools ready${NC}"

# Login shell
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "/usr/bin/zsh" ]; then
	echo ""
	echo "🐚 Switching login shell to zsh..."
	chsh -s /usr/bin/zsh && echo -e "  ${GREEN}✓ Login shell is zsh (log out to apply)${NC}"
fi
