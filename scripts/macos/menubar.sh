#!/bin/bash
# Menu bar / clock
set -euo pipefail
echo "==> menu bar"

# 時計: 曜日 + 24時間 + 秒
defaults write com.apple.menuextra.clock DateFormat -string "EEE d MMM HH:mm:ss"
defaults write com.apple.menuextra.clock IsAnalog -bool false
defaults write com.apple.menuextra.clock FlashDateSeparators -bool false

# バッテリーの割合(%)を表示
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# Spotlight アイコンの非表示は macOS バージョンにより方法が異なるため
# システム設定の "コントロールセンター" → "Spotlight" で手動設定推奨
