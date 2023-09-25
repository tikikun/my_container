#!/bin/bash

set -e

trap '[[ $? -eq 0 ]] && echo "All commands executed successfully!" || echo "Exception occurred!"' EXIT

cp ./fonts/* ${HOME}/Library/Fonts

