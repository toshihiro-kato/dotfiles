#!/bin/bash
# General appearance / behavior
set -euo pipefail
echo "==> general"

# アクセントカラー: パープル
# -1=Graphite 0=Red 1=Orange 2=Yellow 3=Green 4=Blue 5=Purple 6=Pink (multi=未設定)
defaults write -g AppleAccentColor -int 5

# ハイライトカラーをパープル系に追従
defaults write -g AppleHighlightColor -string "0.847059 0.733333 0.815686 Purple"

# スクロールバー: スクロール時に表示
# 値: WhenScrolling | Automatic | Always
defaults write -g AppleShowScrollBars -string "WhenScrolling"

# 新しいアプリを開いたときアニメーションをスキップ
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

# クラッシュレポート / 解析の送信を控えめに
defaults write com.apple.CrashReporter DialogType -string "none"

# 自動アップデートをオフ（手動チェックに）
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 0
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 0
