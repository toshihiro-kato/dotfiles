# 新Mac 移行手順

旧Macから新Macに乗り換えるときの完全チェックリスト。

## 0. 事前準備（旧Macで）

- [ ] dotfiles 最新化: `chezmoi cd && git push`
- [ ] **`~/.config/chezmoi/chezmoi.toml` の場所を確認**（Public リポに乗せない会社固有値が入っている）
  - 引っ越し当日に **AirDrop** で旧Mac → 新Mac へ直接転送するのが最速
  - 保険として **LastPass Secure Note** にも保管（Note 名: `chezmoi config (work)` / 中身は `[data]` セクション全文）
  - AirDrop が使えない環境なら iCloud Drive 経由でも可（例: `~/iCloud Drive/Setup/chezmoi.toml`）
  - 雛形は本ドキュメント 2 章に記載（最悪手で再入力しても 7 行で済む）
- [ ] Brewfile 最新化: `brew bundle dump --file=~/.local/share/chezmoi/Brewfile --force`
- [ ] plist エクスポート（最新化したいなら）:
  ```bash
  defaults export com.superultra.Homerow ~/.local/share/chezmoi/plists/com.superultra.Homerow.plist
  defaults export pl.maketheweb.cleanshotx ~/.local/share/chezmoi/plists/pl.maketheweb.cleanshotx.plist
  /usr/libexec/PlistBuddy -c "Delete :activationKey" ~/.local/share/chezmoi/plists/pl.maketheweb.cleanshotx.plist
  ```
- [ ] 機微情報のバックアップ（`docs/SECRETS.md` 参照）
  - [ ] SSH 鍵 (`~/.ssh/id_*`) → LastPass
  - [ ] AWS 認証情報 (`~/.aws/credentials`) → LastPass
  - [ ] `.npmrc` の GitHub Packages トークン
  - [ ] `~/.netrc`（あれば）
- [ ] Google 日本語入力のユーザー辞書をエクスポート
  - 設定 → 辞書ツール → 管理 → エクスポート → TSV ファイル
  - LastPass の Secure Note か USB 経由で運ぶ
- [ ] アプリのライセンスキー一覧を LastPass に保存
  - CleanShot X / Bartender 5 / Magnet / Affinity Designer/Photo / Eagle / Adobe CC

## 1. 新Macの初期化（macOS の初回起動）

- [ ] Apple ID でサインイン
- [ ] 言語/地域設定
- [ ] **データ移行アシスタントは使わない**（不要なゴミも引き継いでしまうため、クリーン構築する）

## 2. ターミナルで bootstrap

```bash
# 1. ターミナル.app を開く（最初は zsh）

# 2. 先に chezmoi config を復元（template に値を渡すため）
#    旧Mac から AirDrop で chezmoi.toml を受け取り、~/Downloads/ に置いておく
mkdir -p ~/.config/chezmoi
mv ~/Downloads/chezmoi.toml ~/.config/chezmoi/chezmoi.toml
# AirDrop が使えなければ:
#   - LastPass Secure Note "chezmoi config (work)" の中身を貼り付け
#   - もしくは iCloud Drive 経由 or 雛形を見ながら手で書く
#   $EDITOR ~/.config/chezmoi/chezmoi.toml

# 3. bootstrap を実行
curl -fsSL https://raw.githubusercontent.com/toshihiro-kato/dotfiles/main/scripts/bootstrap.sh | bash
```

`~/.config/chezmoi/chezmoi.toml` の雛形:

```toml
[data]
  aws_dev_account_id = "..."
  aws_prod_account_id = "..."
  aws_sso_start_url = "https://...awsapps.com/start/#"
  aws_sso_region = "ap-northeast-1"
  gcp_project = "..."
  npm_work_scope = "..."
  npm_proxy_registry = "https://.../"
```

`bootstrap.sh` が以下を自動実行:
1. Xcode CLT
2. Homebrew
3. chezmoi で dotfiles 取得＆展開
4. `brew bundle`（CLI / cask / mas / VSCode 拡張）
5. mise で言語ランタイム
6. fish を default shell に
7. fisher で fish plugin
8. macOS defaults

## 3. App Store にサインインしてから mas を再実行

`mas` は Apple ID にサインイン済みでないと動かないので、最初の brew bundle で **mas 行はスキップ**される。
App Store.app を開いてサインイン後、再実行:

```bash
brew bundle --file=~/.local/share/chezmoi/Brewfile
```

## 4. 機微情報の復元

- [ ] **SSH 鍵**
  ```bash
  # LastPass から ~/.ssh/ にコピー
  chmod 600 ~/.ssh/id_ed25519 ~/.ssh/id_ed25519_personal
  chmod 644 ~/.ssh/id_ed25519.pub ~/.ssh/id_ed25519_personal.pub
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519
  ```
- [ ] **AWS**
  ```bash
  # ~/.aws/credentials を LastPass から復元
  chmod 600 ~/.aws/credentials
  ```
- [ ] **GitHub CLI**
  ```bash
  gh auth login   # ブラウザ認証 → Keychain に保存
  ```
- [ ] **GitHub Packages トークン (npm)**
  ```bash
  # 新規 PAT を発行（scope: read:packages）
  set -Ux GITHUB_PACKAGES_TOKEN ghp_xxxxx
  ```
- [ ] **社内 PyPI プロキシ** — dotfiles に含めず手動再生成
  - URL は LastPass Secure Note `chezmoi config (work)` に保管（`pypi_proxy_url`）
  - 旧 Mac でのファイル内容を控えてから新 Mac で復元する:
    - `~/.config/uv/uv.toml`
    - `~/.config/pip/pip.conf`

## 5. アプリへサインイン

- [ ] App Store
- [ ] iCloud
- [ ] LastPass
- [ ] Slack（ワークスペースごと）
- [ ] Notion / Notion Calendar
- [ ] Cursor（Cursor Pro アカウント）
- [ ] Claude.app / ChatGPT.app
- [ ] Figma / Pencil
- [ ] GitButler
- [ ] Docker Desktop
- [ ] Raycast（Free 版なので設定は手動エクスポート/インポート）
- [ ] Vivaldi（Vivaldi アカウントで同期）
- [ ] Arc（Arc アカウントで同期）

## 6. ライセンス再認証

- [ ] CleanShot X（`activationKey` を LastPass から）
- [ ] Bartender 5（公式サイトから DMG 落として旧ライセンスでアクティベート）
- [ ] Magnet（MAS インストールでアカウント引き継ぎ）
- [ ] Eagle
- [ ] Affinity Designer 2 / Photo 2（MAS or Affinity Store どちらで購入したかで分岐）
- [ ] Adobe Creative Cloud（CC アプリでサインイン → 各製品インストール）

## 7. アクセシビリティ許可

System Settings → Privacy & Security → Accessibility で以下を ON:
- [ ] Karabiner-Elements / Karabiner-EventViewer
- [ ] AeroSpace
- [ ] Raycast
- [ ] Homerow
- [ ] CleanShot X
- [ ] AutoRaise（使うなら）
- [ ] KeyClu

System Settings → Privacy & Security → Input Monitoring:
- [ ] Karabiner-Elements

System Settings → Privacy & Security → Screen Recording:
- [ ] CleanShot X
- [ ] DemoPro
- [ ] QuickShade

## 8. Google 日本語入力

1. 旧Mac でエクスポートした **TSV ファイル** を新Macに転送
2. システム設定 → キーボード → 入力ソース → Google 日本語入力 を追加
3. メニューバー → Google 日本語入力 → 環境設定 → 辞書ツール → 管理 → インポート → TSV を選択
4. ショートカットキー設定:
   - 一般タブ → キー設定: カスタム
   - 入力補助タブ → 数字や記号は基本的に半角

## 9. Raycast（Pro 未契約のため手動）

旧Mac で:
- Settings → Quicklinks/Snippets/Hotkeys を1個ずつ手動メモ
- Extensions の有効/無効リストもメモ

新Mac で同じ Extensions をインストール、Quicklinks/Snippets を再登録。

## 10. 会社配布アプリ（情シスへ依頼）

新Mac 受領後、Atrae 情シスに以下を依頼:

- [ ] **Atrae Self-Service**（Jamf Pro 管理ポータル — これがあれば残りは自分で取れる場合あり）
- [ ] **Netskope Client**（SASE エージェント）
- [ ] **Netskope Endpoint DLP**
- [ ] **SentinelOne**（EDR）
- [ ] **AWS VPN Client**（社内固有 .ovpn 設定）
- [ ] **Amazon Q**（業務利用なら）
- [ ] **Adobe Creative Cloud アカウントの権限確認**（Illustrator 等使う場合）

## 11. 個別ダウンロードアプリ（Brewfile cask に無いもの）

公式サイトから直接 DMG を取得:

- [ ] **Bartender 5** — https://www.macbartender.com/ （cask `bartender` は v6 配布のため、旧ライセンスを使う場合は公式から v5 を取得）
- [ ] **AutoRaise** — https://github.com/sbmpost/AutoRaise/releases （cask 無し）
- [ ] **AppCode** — JetBrains Toolbox 経由（cask 無し、製品は EOL のため代替推奨）
- [ ] **Pencil.app** — https://www.gethighagency.com/pencil
- [ ] **Belkin Dock Utility** — Belkin 公式
- [ ] **Adobe Illustrator / Adobe Creative Cloud** — Creative Cloud アプリから
- [ ] **Dia** — https://www.diabrowser.com/ （Arc 後継、利用継続するなら）
- [ ] **「ライフプラン」アプリ** — App Store の名称検索で再インストール（mas search で ID 不明）

## 12. ハードウェア依存設定

- [ ] Logi Options+（Logi アカウントでデバイス設定同期）
- [ ] VIA / QMK Toolbox（キーボード）
- [ ] DisplayLink Manager（cask `displaylink` で入るが、デバイス接続後に Screen Recording 許可が必要）

## 13. 仕上げ

- [ ] ログアウト → ログインで macOS defaults を完全反映
- [ ] 普段使うコマンドが動くか確認:
  ```bash
  fish --version
  mise current
  gh auth status
  ghq list
  ```
- [ ] 旧Macは初期化前に Time Machine フルバックアップ（保険）

## 14. 旧Macのクリーンアップ（必要なら）

```bash
# Apple ID サインアウト
# Find My Mac オフ
# システム → 一般 → 転送またはリセット → すべてのコンテンツと設定を消去
```
