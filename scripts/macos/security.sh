#!/bin/bash
# Security & Privacy
set -euo pipefail
echo "==> security"

# パスワード要求: スリープ/スクリーンセーバー解除直後
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# ファイアウォール ON
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# Touch ID で sudo を許可（既に行があれば追加しない）
PAM_FILE="/etc/pam.d/sudo"
if ! sudo grep -q "pam_tid.so" "$PAM_FILE"; then
  echo "    enabling Touch ID for sudo (/etc/pam.d/sudo)"
  sudo sed -i '' '1s|^|auth       sufficient     pam_tid.so\n|' "$PAM_FILE"
fi
