#!/bin/bash
# Screensaver
set -euo pipefail
echo "==> screensaver"

# スクリーンセーバー無効（idleTime=0）
defaults -currentHost write com.apple.screensaver idleTime -int 0
