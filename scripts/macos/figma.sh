#!/bin/bash
# Figma Desktop: メニューショートカット 25 件を NSUserKeyEquivalents で設定
#
# - Plugins → Saved plugins 配下 24 件 + Object → Main Component 1 件
# - キー形式は ESC (0x1B) 区切りのフルメニューパス
#   → System Settings UI と互換、同名メニューがあっても誤マッチしない
# - System Settings UI への表示には com.apple.universalaccess への書き込みが
#   必要だが、macOS Ventura+ で TCC 保護されているため初回は失敗する。
#   ショートカット自体は universalaccess 登録の有無に関わらず動作する。
#   UI 表示が必要なら docs/MIGRATION.md の手順 7.5 を参照。
#
# 注: -dict 形式の defaults write は既存の NSUserKeyEquivalents 全体を上書きする。
#     他経路で追加したショートカットがあれば消える点に注意。
set -euo pipefail
echo "==> figma desktop shortcuts"

if [[ ! -d "/Applications/Figma.app" ]]; then
  echo "    skip: /Applications/Figma.app not found"
  exit 0
fi

ESC=$'\033'
P="${ESC}Plugins${ESC}Saved plugins${ESC}"

defaults write com.figma.Desktop NSUserKeyEquivalents -dict \
  "${P}Master${ESC}Create Component from Objects"          "^\$m" \
  "${P}Japanese Font Picker"                               "^\$j" \
  "${P}Quantizer"                                          "^\$q" \
  "${P}Nisa Text${ESC}Split"                               "^\$v" \
  "${P}Iconify"                                            "^\$i" \
  "${P}Similayer"                                          "^\$y" \
  "${P}Icons8 — icons, illustrations, photos"              "^\$8" \
  "${P}Typestyles${ESC}Typestyles"                         "^\$t" \
  "${P}Spaciiing"                                          "^\$x" \
  "${P}Design Lint"                                        "^\$l" \
  "${P}Minimap"                                            "^\$p" \
  "${P}Style Organizer"                                    "^\$s" \
  "${P}Handy Components"                                   "^\$h" \
  "${P}Automator"                                          "^\$a" \
  "${P}Font Replacer"                                      "^\$f" \
  "${P}Unsplash"                                           "^\$u" \
  "${P}Instance Finder"                                    "^\$d" \
  "${P}Batch Styler"                                       "^\$b" \
  "${P}Figma Autoname"                                     "^\$g" \
  "${P}Font Preview"                                       "^\$k" \
  "${P}Ink Wireframe"                                      "^\$w" \
  "${P}Bunch description change"                           "^\$n" \
  "${P}Chroma Colors"                                      "^\$c" \
  "${P}Text Edit"                                          "^\$," \
  "${ESC}Object${ESC}Main Component${ESC}Go to Main Component" "^\$o"

# System Settings UI への表示のため universalaccess へ登録（TCC 保護）
if defaults write com.apple.universalaccess com.apple.custommenu.apps -array-add "com.figma.Desktop" 2>/dev/null; then
  echo "    registered com.figma.Desktop in universalaccess (visible in System Settings UI)"
else
  cat <<'NOTE'
    [info] universalaccess write was blocked (TCC / Full Disk Access required).
           The 25 shortcuts WILL WORK regardless; they just won't appear in
           System Settings → Keyboard → App Shortcuts UI.

           To make them visible (one-time, per Mac):
             1. System Settings → Keyboard → Keyboard Shortcuts → App Shortcuts
             2. Click + and add ANY one shortcut for Figma manually
             3. Re-run: bash scripts/macos/figma.sh
NOTE
fi

killall cfprefsd 2>/dev/null || true
echo "    please restart Figma to apply (osascript -e 'quit app \"Figma\"' && open -a Figma)"
