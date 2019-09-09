#!/bin/bash

[ -z "$HOME" ] && export HOME=$(getent passwd $(whoami) | cut -d: -f6)
REPODIR=$(git rev-parse --show-toplevel)

# Fetch submodules
git submodule foreach git pull origin master
git submodule update --init --recursive

# Cleanup before linking
rm -rf $HOME/.vimrc $HOME/.vim

# Install vim files
ln -s ${REPODIR}/vimrc $HOME/.vimrc
ln -s ${REPODIR}/vim $HOME/.vim
