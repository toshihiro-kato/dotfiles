#!/bin/bash
# Finder settings
set -euo pipefail
echo "==> finder"

# デスクトップに表示する項目
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true

# 新規 Finder ウィンドウでホームディレクトリを開く
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# すべてのファイル名拡張子を表示
defaults write -g AppleShowAllExtensions -bool true

# 拡張子を変更する前に警告を表示
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool true

# iCloud Drive から削除する前に警告を表示
defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool true

# ゴミ箱を空にする前に警告を表示
defaults write com.apple.finder WarnOnEmptyTrash -bool true

# 30 日後にゴミ箱から項目を削除
defaults write com.apple.finder FXRemoveOldTrashItems -bool true

# サイドバーにホームディレクトリを表示するためのデフォルト挙動
defaults write com.apple.finder ShowSidebar -bool true

# パスバー / ステータスバー表示
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# 隠しファイルを表示（任意・お好みで）
# defaults write com.apple.finder AppleShowAllFiles -bool true
