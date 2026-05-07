#!/bin/bash
# macOS defaults: 全カテゴリ実行のエントリポイント
# Usage: bash scripts/macos/all.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Applying macOS defaults..."
echo "    (some changes require logout/restart to take effect)"
echo

# 管理者権限が必要な処理があるので最初に sudo を取得しておく
sudo -v

bash "$SCRIPT_DIR/trackpad.sh"
bash "$SCRIPT_DIR/keyboard.sh"
bash "$SCRIPT_DIR/finder.sh"
bash "$SCRIPT_DIR/dock.sh"
bash "$SCRIPT_DIR/screenshot.sh"
bash "$SCRIPT_DIR/hotcorners.sh"
bash "$SCRIPT_DIR/menubar.sh"
bash "$SCRIPT_DIR/sound.sh"
bash "$SCRIPT_DIR/general.sh"
bash "$SCRIPT_DIR/security.sh"
bash "$SCRIPT_DIR/screensaver.sh"
bash "$SCRIPT_DIR/apps.sh"

# 反映のためにいくつかのアプリを再起動
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true
killall cfprefsd 2>/dev/null || true

echo
echo "==> Done. Please log out and log back in for all changes to take effect."
