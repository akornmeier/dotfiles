#!/bin/sh
#
# n
#
# Installs n (node version manager)

# Check for n
if test ! $(which n)
then
  echo "- Installing n..."

  # Install the correct homebrew for each OS type
  if test "$(uname)" = "Darwin"
  then
    ruby -e "$(curl -L git.io/n-install | bash)"
  fi

  echo "- n installation complete..."
fi

exit 0