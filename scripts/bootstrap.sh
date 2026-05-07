#!/bin/bash
# bootstrap.sh - 新Mac セットアップエントリポイント
# 1コマンドで開発環境をまるごと再構築する
#
# 使い方（新Macで）:
#   curl -fsSL https://raw.githubusercontent.com/toshihiro-kato/dotfiles/main/scripts/bootstrap.sh | bash
# または:
#   git clone https://github.com/toshihiro-kato/dotfiles
#   cd dotfiles && bash scripts/bootstrap.sh

set -euo pipefail

REPO="toshihiro-kato/dotfiles"
SOURCE_DIR="${HOME}/.local/share/chezmoi"

log() { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }

# ============================================================
# 1. Xcode Command Line Tools
# ============================================================
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools (GUI prompt will appear)"
  xcode-select --install || true
  log "After CLT install completes, re-run this script."
  exit 0
fi

# ============================================================
# 2. Homebrew
# ============================================================
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Homebrew shellenv (Apple Silicon と Intel の両対応)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ============================================================
# 3. chezmoi で dotfiles を展開
# ============================================================
if ! command -v chezmoi >/dev/null 2>&1; then
  log "Installing chezmoi"
  brew install chezmoi
fi

if [[ ! -d "$SOURCE_DIR/.git" ]]; then
  log "Initializing chezmoi from $REPO"
  chezmoi init --apply "$REPO"
else
  log "chezmoi source already exists, applying"
  chezmoi apply
fi

# ============================================================
# 4. Brewfile 適用
# ============================================================
if [[ -f "$SOURCE_DIR/Brewfile" ]]; then
  log "Running brew bundle"
  brew bundle --file="$SOURCE_DIR/Brewfile" || warn "some bundles failed; review above"
fi

# ============================================================
# 5. mise 言語ランタイム
# ============================================================
if command -v mise >/dev/null 2>&1; then
  log "Installing mise tools"
  mise install
fi

# ============================================================
# 6. fish を default shell に
# ============================================================
FISH_PATH="$(command -v fish)"
if [[ -n "$FISH_PATH" ]]; then
  if ! grep -q "^${FISH_PATH}$" /etc/shells; then
    log "Adding fish to /etc/shells (sudo required)"
    echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
  fi
  if [[ "$SHELL" != "$FISH_PATH" ]]; then
    log "Changing default shell to fish (sudo may be required)"
    chsh -s "$FISH_PATH" || warn "chsh failed; run manually: chsh -s $FISH_PATH"
  fi
fi

# ============================================================
# 7. fisher で fish plugin 一括導入
# ============================================================
if [[ -f "$HOME/.config/fish/fish_plugins" ]]; then
  log "Installing fisher plugins"
  fish -c "fisher update" || warn "fisher update failed; run manually"
fi

# ============================================================
# 8. macOS defaults
# ============================================================
if [[ -d "$SOURCE_DIR/scripts/macos" ]]; then
  log "Applying macOS defaults (sudo may prompt)"
  bash "$SOURCE_DIR/scripts/macos/all.sh" || warn "some macos defaults failed"
fi

# ============================================================
# 9. 仕上げメッセージ
# ============================================================
cat <<'EOF'

========================================================
✅ Bootstrap complete!

Manual steps required:
  - Sign in to App Store and run: brew bundle --file=~/.local/share/chezmoi/Brewfile
  - Sign in to: Slack / Notion / Cursor / Claude / GitButler / Docker / Raycast
  - gh auth login           (GitHub CLI authentication)
  - Restore SSH keys to ~/.ssh/ (from 1Password)
  - Restore AWS credentials to ~/.aws/credentials (from 1Password)
  - Import Google IME user dictionary (TSV)
  - Re-enter licenses for: CleanShot X, Bartender, Magnet, Affinity, Adobe CC
  - Grant accessibility permissions: Karabiner, Aerospace, Raycast, Homerow

See docs/MIGRATION.md for the full checklist.

  Log out and back in for all macOS settings to fully take effect.
========================================================
EOF
