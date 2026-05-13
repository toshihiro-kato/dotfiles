# dotfiles

[chezmoi](https://www.chezmoi.io/) で管理する macOS 開発環境セットアップ。

## クイックスタート (新Mac)

```bash
# 1コマンドで全部
curl -fsSL https://raw.githubusercontent.com/toshihiro-kato/dotfiles/main/scripts/bootstrap.sh | bash

# または明示的に
git clone https://github.com/toshihiro-kato/dotfiles ~/dotfiles
bash ~/dotfiles/scripts/bootstrap.sh
```

完了後、`docs/MIGRATION.md` に従って手動ステップ（ログイン、ライセンス、SSH鍵移送等）を実施。

## 構成

```
.
├── README.md
├── Brewfile                 # CLI / GUI / mas / VSCode 拡張
├── home/                    # chezmoi 管理ファイル → $HOME へ展開
│   ├── dot_aerospace.toml      → ~/.aerospace.toml
│   ├── dot_gitconfig           → ~/.gitconfig
│   ├── dot_config/...          → ~/.config/...
│   ├── dot_claude/...          → ~/.claude/...
│   └── ...
├── plists/                  # アプリ別 plist（GUI 設定）
│   ├── com.superultra.Homerow.plist
│   └── pl.maketheweb.cleanshotx.plist
├── scripts/
│   ├── bootstrap.sh            # 新Mac エントリポイント
│   └── macos/                  # macOS defaults スクリプト群
│       ├── all.sh              # 全部実行
│       ├── trackpad.sh
│       ├── keyboard.sh
│       ├── finder.sh
│       ├── dock.sh
│       ├── ...
└── docs/
    ├── MIGRATION.md         # 新Macへの引っ越し手順
    └── SECRETS.md           # 機微情報の取扱い
```

## 管理対象

### 自動化される領域

- **CLI / GUI アプリ**: Homebrew Brewfile + mas
- **設定ファイル**: chezmoi（fish, nvim, wezterm, starship, karabiner 等）
- **言語ランタイム**: mise（node, python, ruby, go, bun）
- **macOS システム設定**: defaults スクリプト
- **VSCode / Cursor 拡張**: Brewfile vscode 行
- **fish プラグイン**: fisher + `fish_plugins`
- **アプリ GUI 設定（一部）**: plist インポート（Homerow, CleanShot X）
- **Figma メニューショートカット**: `scripts/macos/figma.sh` で 25 件の `Ctrl+Shift+<key>` を設定

### 自動化されない領域（手動）

- App Store サインイン
- 各 SaaS のサインイン (Slack / Notion / Cursor / Claude / Docker 等)
- ライセンスキー（CleanShot X / Bartender / Magnet / Affinity / Adobe CC）
- SSH 鍵（`~/.ssh/id_*`）の移送
- AWS 認証情報（`~/.aws/credentials`）の移送
- Google 日本語入力のユーザー辞書（TSV エクスポート/インポート）
- GitHub PAT の再発行（`gh auth login`）
- アクセシビリティ許可（Karabiner / Aerospace / Raycast / Homerow）
- Figma メニューショートカットの System Settings UI 表示（TCC 制約で初回 1 件のみ手動追加が必要、`docs/MIGRATION.md` §7.5 参照）
- 会社配布アプリ（Atrae Self-Service / Netskope / SentinelOne）

詳細は [docs/MIGRATION.md](docs/MIGRATION.md) を参照。

## 日常運用

### 設定を変更したとき

```bash
# ローカルの設定ファイルを直接編集 → chezmoi に反映
chezmoi add ~/.config/foo/bar.toml

# または chezmoi 側を直接編集 → ローカルに反映
chezmoi edit ~/.config/foo/bar.toml
chezmoi apply
```

### Brewfile を更新したとき

```bash
# 現状を Brewfile にエクスポート
brew bundle dump --file=~/.local/share/chezmoi/Brewfile --force

# 同期: Brewfile に書かれてないものをアンインストール
brew bundle cleanup --file=~/.local/share/chezmoi/Brewfile
```

### plist を更新したとき

```bash
defaults export com.superultra.Homerow ~/.local/share/chezmoi/plists/com.superultra.Homerow.plist
```

### コミット / プッシュ

```bash
chezmoi cd
git add -A
git commit -m "chore: update settings"
git push
```

## 関連ドキュメント

- [docs/MIGRATION.md](docs/MIGRATION.md) - 新Macへの引っ越し手順
- [docs/SECRETS.md](docs/SECRETS.md) - 機微情報の取扱い
