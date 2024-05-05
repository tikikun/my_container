#!/bin/bash

set -e

trap '[[ $? -eq 0 ]] && echo "All commands executed successfully!" || echo "Exception occurred!"' EXIT

# Ensure the directory does not exist before proceeding.
if [ ! -d ~/.config/nvim ]; then
    echo "nvim directory does not exist. Proceeding with setup..."
    mkdir -p ~/.config/nvim # This will create the directory if it does not exist.
    ln -sf $(pwd)/vim_setup ~/.config/nvim
    ln -sf $(pwd)/dotfiles/.tmux.conf ~/.tmux.conf
    ln -sf $(pwd)/dotfiles/.zshrc ~/.zshrc
    ln -sf $(pwd)/../openai_key ~/openai_key
else
    echo "nvim directory already exists. Aborting setup."
fi

