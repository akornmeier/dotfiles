# Must clone this repo before starting the installation
# git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"

source "${HOME}/.zgen/zgen.zsh"
if ! zgen saved; then
echo "Creating a zgen save"

    # prezto and modules
    zgen prezto
    # zgen prezto git
    zgen prezto utility
    zgen prezto completion
    zgen prezto autosuggestions
    zgen prezto spectrum
    zgen prezto syntax-highlighting
    zgen prezto history-substring-search
    zgen prezto prompt

    zgen load djui/alias-tips
    zgen load supercrabtree/k
    zgen load agkozak/zsh-z
    zgen load mafredri/zsh-async
    zgen load starship/starship

    #completions
    zgen load zsh-users/zsh-completions src

    # prompt
    # zgen prezto prompt theme 'starship'
    # zgen prezto prompt theme 'pure'

    #save to init script
    zgen save
fi
