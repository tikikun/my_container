#!/bin/bash

set -e

trap '[[ $? -eq 0 ]] && echo "All commands executed successfully!" || echo "Exception occurred!"' EXIT

# mkdir -p ~/.config/nvim
if [ -d ~/.config/nvim ] && [ -z "$(ls -A ~/.config/nvim)" ]; then
    echo "Directory is empty. Proceeding with setup..."
    # mkdir -p ~/.config/nvim # Uncomment if there's any possibility the directory doesn't exist.
    ln -sf $(pwd)/vim_setup ~/.config/nvim
    ln -sf $(pwd)/dotfiles/.tmux.conf ~/.tmux.conf
    ln -sf $(pwd)/dotfiles/.zshrc ~/.zshrc
    ln -sf $(pwd)/../openai_key ~/openai_key
else
    echo "Directory is not empty or does not exist. Aborting setup."
fi
