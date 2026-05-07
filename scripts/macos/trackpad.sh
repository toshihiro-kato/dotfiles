#!/bin/bash
# Trackpad / Mouse settings
set -euo pipefail
echo "==> trackpad / mouse"

# 速度（爆速）
defaults write -g com.apple.mouse.scaling -float 16
defaults write -g com.apple.trackpad.scaling -float 16

# 1本指タップでクリック
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write -g com.apple.mouse.tapBehavior -int 1

# 3本指ドラッグ
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# 4本指で左右スワイプしてフルスクリーンアプリ間を移動
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2

# 4本指で下にスワイプして Mission Control
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 2

# 3本指タップで「調べる/Data 検出」
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 2

# ダブルクリック間隔: 速い
defaults write -g com.apple.mouse.doubleClickThreshold -float 0.3
