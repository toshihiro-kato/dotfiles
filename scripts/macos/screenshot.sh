#!/bin/bash
# Screenshot settings
set -euo pipefail
echo "==> screenshot"

mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

# シャドウ無し PNG
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture type -string "png"
