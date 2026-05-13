#!/bin/bash
# macOS defaults: 全カテゴリ実行のエントリポイント
#
# ⚠️  会社支給 Mac (Atrae) では Jamf Pro による MDM プロファイルが
#     一部の defaults を上書きする可能性がある。
#     特に hotcorners は MDM 側で右下=ロック画面に固定されている。
#     bootstrap.sh からは自動実行されない（OPT-IN）。
#
# Usage:
#   bash scripts/macos/all.sh --apply           # 全カテゴリ実行
#   bash scripts/macos/all.sh --apply --skip hotcorners  # hotcorners 除外
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

APPLY=0
SKIP=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY=1; shift ;;
    --skip)  SKIP+=("$2"); shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ "$APPLY" -ne 1 ]]; then
  cat <<'USAGE'
This script applies macOS defaults that may conflict with MDM profiles
on company-managed Macs. It is OPT-IN to avoid surprise overrides.

Run explicitly:
  bash scripts/macos/all.sh --apply
  bash scripts/macos/all.sh --apply --skip hotcorners
USAGE
  exit 0
fi

skipped() {
  local name="$1"
  for s in "${SKIP[@]}"; do
    [[ "$s" == "$name" ]] && return 0
  done
  return 1
}

echo "==> Applying macOS defaults..."
echo "    (some changes require logout/restart to take effect)"
echo

# 管理者権限が必要な処理があるので最初に sudo を取得しておく
sudo -v

for name in trackpad keyboard finder dock screenshot hotcorners menubar sound general security screensaver apps figma; do
  if skipped "$name"; then
    echo "==> [skip] $name"
    continue
  fi
  bash "$SCRIPT_DIR/$name.sh"
done

# 反映のためにいくつかのアプリを再起動
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true
killall cfprefsd 2>/dev/null || true

echo
echo "==> Done. Please log out and log back in for all changes to take effect."
