#!/bin/bash
# Hot corners
# 値: 1=Disabled 2=Mission Control 3=Application Windows 4=Desktop 5=Start Screen Saver
#     6=Disable Screen Saver 7=Dashboard 10=Put Display to Sleep 11=Launchpad 12=Notification Center
set -euo pipefail
echo "==> hot corners"

# 左上: Mission Control
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 0

# 左下: アプリケーションウィンドウ
defaults write com.apple.dock wvous-bl-corner -int 3
defaults write com.apple.dock wvous-bl-modifier -int 0

# 右上: Launchpad
defaults write com.apple.dock wvous-tr-corner -int 11
defaults write com.apple.dock wvous-tr-modifier -int 0

# 右下: デスクトップ
defaults write com.apple.dock wvous-br-corner -int 4
defaults write com.apple.dock wvous-br-modifier -int 0
