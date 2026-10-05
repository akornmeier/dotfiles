#!/bin/bash
#
# macOS steps for bin/dot, which sources this file on Darwin.
# Defines the OS interface every <os>/dot.sh provides:
#   os_git_credential  git credential helper written to gitconfig.local
#   os_links           extra "src dst" link pairs beyond *.symlink -> ~/.name
#   os_bootstrap       make the package manager available
#   os_install         install packages and runtimes
#   os_configure       apply system settings (last step of `dot install`)
#   os_update          upgrade packages

os_git_credential='osxkeychain'
os_links=()

os_bootstrap() {
	echo ""
	echo "🍺 Checking for Homebrew..."
	if command -v brew &> /dev/null; then
		echo -e "  ${GREEN}✓ Homebrew is already installed${NC}"
	else
		echo ""
		echo "  Installing Homebrew..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		echo -e "  ${GREEN}✓ Homebrew installed${NC}"
	fi
}

os_install() {
	echo ""
	echo "🍺 Installing Homebrew packages..."
	echo ""
	cd "$DOTFILES"
	brew bundle install
	echo -e "  ${GREEN}✓ Homebrew packages installed${NC}"

	source "$DOTFILES/macos/install.sh"

	echo ""
	echo -e "${BLUE}🔧 Setting up FNM and Node.js...${NC}"

	# Set up FNM environment
	eval "$(fnm env --use-on-cd --version-file-strategy=recursive --corepack-enabled --shell bash)"

	# Check if LTS is already installed and set as default
	CURRENT_NODE=$(fnm current 2>/dev/null || echo "none")
	if fnm list | grep -q "lts-latest" && [ "$CURRENT_NODE" != "none" ]; then
		echo -e "  ${GREEN}✓ Node.js LTS already installed: $CURRENT_NODE${NC}"
	else
		echo ""
		echo "  Installing latest Node.js LTS version..."
		fnm install --lts
		fnm default lts-latest
		echo -e "  ${GREEN}✓ Installed Node.js $(fnm current)${NC}"
	fi

	# Node's bundled corepack lags behind pnpm (e.g. Node 22's 0.34 can't run
	# pnpm >= 11), so upgrade it in the default Node install.
	npm install -g corepack@latest

	echo -e "  ${YELLOW}- 📦 node: $(node --version)${NC}"
	echo -e "  ${YELLOW}- 📦 npm: $(npm --version)${NC}"
	echo -e "  ${YELLOW}- 📦 npx: $(npx --version)${NC}"
	echo -e "  ${YELLOW}- 📦 corepack: $(corepack --version)${NC}"
	echo -e "  ${GREEN}✓ FNM setup complete!${NC}"

	# Install npm global packages (add packages to NPM_GLOBALS array as needed)
	NPM_GLOBALS=(
		# Add global packages here, e.g.: "package-name"
	)
	if [ ${#NPM_GLOBALS[@]} -gt 0 ]; then
		echo ""
		echo -e "${BLUE}📦 Installing npm global packages...${NC}"
		for pkg in "${NPM_GLOBALS[@]}"; do
			if npm list -g "$pkg" &>/dev/null; then
				echo -e "  ${GREEN}✓ $pkg already installed${NC}"
			else
				echo "  Installing $pkg..."
				npm install -g "$pkg"
				echo -e "  ${GREEN}✓ $pkg installed${NC}"
			fi
		done
	fi
}

os_configure() {
	echo ""
	echo "============================================================"
	echo -e "${BLUE}🍏 Configuring macOS defaults...${NC}"
	echo "============================================================"

	ensure_sudo

	source "$DOTFILES/macos/set-defaults.sh"
}

os_update() {
	echo ""
	echo "============================================================"
	echo -e "${BLUE}🍺 Updating Homebrew...${NC}"
	echo "============================================================"

	echo ""
	echo "🔍 Checking for Homebrew updates..."
	echo ""
	brew update
	echo -e "  ${GREEN}✓ Homebrew updated${NC}"

	echo ""
	echo "📦 Checking for package updates..."
	# Check if there are any outdated packages before upgrading
	OUTDATED=$(brew outdated)
	if [ -n "$OUTDATED" ]; then
		echo "$OUTDATED" | sed 's/^/  /'
		echo ""
		brew upgrade
		echo -e "  ${GREEN}✓ Packages upgraded${NC}"
	else
		echo -e "  ${GREEN}✓ All packages are up to date${NC}"
	fi

	echo ""
	echo "📦 Checking Brewfile for missing packages..."
	cd "$DOTFILES"
	# Use brew bundle check to see if anything is missing
	if ! brew bundle check &>/dev/null; then
		echo ""
		echo "  Installing missing packages..."
		brew bundle install
		echo -e "  ${GREEN}✓ Missing packages installed${NC}"
	else
		echo -e "  ${GREEN}✓ All Brewfile packages are installed${NC}"
	fi

	echo ""
	echo "🧹 Cleaning up Homebrew..."
	brew cleanup
	echo -e "  ${GREEN}✓ Cleanup complete${NC}"
}
