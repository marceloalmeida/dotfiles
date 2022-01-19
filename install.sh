#!/bin/bash

[ -z "$HOME" ] && export HOME=$(getent passwd $(whoami) | cut -d: -f6)
REPODIR=$(git rev-parse --show-toplevel)

# Fetch submodules
git submodule foreach git pull origin master
git submodule update --init --recursive

# Cleanup before linking
rm -rf $HOME/.vimrc $HOME/.vim
rm -f $HOME/.gitconfig

# Install vim files
ln -s ${REPODIR}/vimrc $HOME/.vimrc
ln -s ${REPODIR}/vim $HOME/.vim

# Install gitconfig files
ln -s ${REPODIR}/gitconfig $HOME/.gitconfig

# Install fzf files
ln -s ${REPODIR}/fzf.zsh $HOME/.fzf.zsh


## Install oh-my-zsh
#sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#
## Install Startship
#sh -c "$(curl -fsSL https://starship.rs/install.sh)"
#
## Install spaceship theme
#ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"\n
#git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1\n
#
## Install z
#wget https://raw.githubusercontent.com/rupa/z/master/z.sh -O $HOME/.z
