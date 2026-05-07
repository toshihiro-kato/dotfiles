#!/bin/bash
# App-specific plist 復元
# 個別アプリの GUI 設定を plist インポートで一括復元する
set -euo pipefail
echo "==> apps (plist import)"

PLIST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../plists" && pwd)"

import_plist() {
  local domain="$1"
  local file="$PLIST_DIR/${domain}.plist"
  if [[ -f "$file" ]]; then
    echo "    importing $domain"
    defaults import "$domain" "$file"
  else
    echo "    skip: $domain (no plist found)"
  fi
}

# Homerow（ライセンスキーは含まれていない: 別途入力必要）
import_plist "com.superultra.Homerow"

# CleanShot X（activationKey は除去済み: 別途入力必要）
import_plist "pl.maketheweb.cleanshotx"
