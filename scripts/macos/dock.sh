#!/bin/bash
# Dock settings
set -euo pipefail
echo "==> dock"

# 左側に配置
defaults write com.apple.dock orientation -string "left"

# 自動的に表示/非表示
defaults write com.apple.dock autohide -bool true

# 表示エフェクト: スケール
defaults write com.apple.dock mineffect -string "scale"

# 起動アニメーション無効化
defaults write com.apple.dock launchanim -bool false

# Dock 表示 / 非表示の遅延を最小化
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.4

# 最近使ったアプリを Dock に表示しない
defaults write com.apple.dock show-recents -bool false
