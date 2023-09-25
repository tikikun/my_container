#!/bin/bash

set -e

trap '[[ $? -eq 0 ]] && echo "All commands executed successfully!" || echo "Exception occurred!"' EXIT

mkdir -p ~/.config/nvim
ln -sf $(pwd)/vim_setup ~/.config/nvim
ln -sf $(pwd)/dotfiles/.tmux.conf ~/.tmux.conf
ln -sf $(pwd)/dotfiles/.zshrc ~/.zshrc
