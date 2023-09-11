#!/bin/bash

set -e

trap '[[ $? -eq 0 ]] && echo "All commands executed successfully!" || echo "Exception occurred!"' EXIT

mkdir -p ~/.config/nvim
cp -r ./vim_setup/* ~/.config/nvim
cp -r dotfiles/. ~/
