# TK Dotfiles

This repo contains my dotfiles. There are many others like it, but this one is mine. My dotfiles are my best friend. It is my life. I must master it as I must master my life. Without me, my dotfiles are useless. Without my dotfiles, I am useless.

Forked from @Holman's dotfiles, I took his general premise and edited them to fit my own needs.
They are split into the main areas I use (JavaScript, Node, git, system libraries, and so on), so the project is structured accordingly.

## What's inside

A lot of stuff. Seriously, a lot of stuff. Check them out in the file browser
above and see what components may mesh with you.
[Fork it](https://github.com/akornmeier/dotfiles/fork), remove what you don't
use, and build on what you do use.

## components

Below is the general layout of my setup. Please review this _**before**_
running the install scripts.

- **bin/**: Anything in `bin/` will be added to your `$PATH` and 
  available everywhere.
- **Brewfile**: Manages four types of applications:

  1. Brew Tap - service level tasks
  2. Brewfiles - apps/plugins
  3. Cask - OS app like Chrome, Discord, Warp, and Zoom
  4. Mas - app from Mac App Store like: Lungo, Magnet, and Be Focused
  
  **You'll want to edit this file before you run the initial setup**.
  
- **topic/\*.zsh**: Any files ending in `.zsh` get loaded into your
  environment.
- **topic/path.zsh**: Any file named `path.zsh` is loaded first and is
  expected to set up `$PATH` or similar.
- **topic/completion.zsh**: Any file named `completion.zsh` is loaded
  last and is expected to set up autocomplete.
- **topic/\*.symlink**: Any files ending in `*.symlink` get symlinked into
  your `$HOME`. This is so you can keep all of those versioned in your dotfiles
  but still keep those autoloaded files in your home directory. These get
  symlinked in when you run `script/bootstrap`.

## Getting Started

The main file you'll want to change right off the bat is `zsh/zshrc.symlink`,
which sets up a few paths that'll be different on your particular machine.

Run this:

```sh
// clone (or fork) the repo
git clone https://github.com/akornmeier/dotfiles.git ~/.dotfiles

// go to the new directory
cd ~/.dotfiles

// 1. setup the pathing and config files
script/bootstrap

// 2. install os defaults and brew files
script/install
```

This will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

## Updates to keep things fresh

Run this simple command from any directory:

```sh
dot
```

`dot` is a simple script that you can from from time to time to keep your 
environment fresh and up-to-date. You can find this script in `bin/`.
