# check if autocomplete is already installed
if [ ! -d ~/.oh-my-zsh/custom/plugins/git-autocomplete ]; then
  echo "Installing git-autocomplete..."
  curl -s https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/plugins/git/git.plugin.zsh > ~/.oh-my-zsh/custom/plugins/git-autocomplete/git.plugin.zsh
else 
  echo "git-autocomplete already installed."
fi