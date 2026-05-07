#!/bin/bash
# Sound settings
set -euo pipefail
echo "==> sound"

# 起動音をオフ (Apple Silicon 必須: nvram)
sudo nvram StartupMute=%01

# UI サウンドエフェクト
defaults write -g com.apple.sound.uiaudio.enabled -bool false
defaults write -g com.apple.sound.beep.feedback -int 0
