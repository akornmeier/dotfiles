#!/bin/bash
# Install TPM (Tmux Plugin Manager)

echo ""
echo "Setting up tmux..."

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
	echo "  Installing TPM..."
	git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
	echo -e "  ${GREEN}✓ TPM installed${NC}"
else
	echo -e "  ${GREEN}✓ TPM already installed${NC}"
fi

# Install tmux plugins non-interactively
if command -v tmux &>/dev/null && [ -d "$TPM_DIR" ]; then
	echo "  Installing tmux plugins..."
	if "$TPM_DIR/bin/install_plugins" 2>&1; then
		echo -e "  ${GREEN}✓ Tmux plugins installed${NC}"
	else
		echo -e "  ${YELLOW}⚠ Tmux plugin installation failed (exit $?)${NC}" >&2
	fi
fi
