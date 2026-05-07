#!/bin/bash
# Keyboard settings
set -euo pipefail
echo "==> keyboard"

# キーリピート速度（爆速）
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1

# キーボードバックライトを 5 秒で消灯
defaults write com.apple.BezelServices kDimTime -int 5

# 全コントロール（タブで進む対象）を有効化
defaults write -g AppleKeyboardUIMode -int 3

# 自動大文字化／スマートクオート／スマートダッシュなどはオフ
defaults write -g NSAutomaticCapitalizationEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
