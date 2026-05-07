# 会社支給 Mac リプレース手順 (Atrae)

Atrae 正社員の職場 Mac リプレース時の専用手順。
個人 Mac の `MIGRATION.md` と内容が重複するが、**会社 Mac は Atrae 公式フローを優先**するため本書を起点にする。

## 参照すべき公式マニュアル（Atrae Notion）

- **PC リプレース全体フロー**: `notion://atrae/PC-18854be6e7ad80f78a78d33e74f8d086`
- **macbook 初期化マニュアル（旧 Mac の返却前）**: `notion://atrae/macbook-18854be6e7ad804aa6ede2c0b8fb1ce7`

公式手順が更新されている可能性があるので、**最初に Notion 側を確認** してから本書と照らし合わせる。

## 全体フロー（時系列）

```
1. 新 Mac 受領
        ↓
2. macOS 初期セットアップ（公式マニュアルに従う）
   - 「新しい Mac として設定」
   - WiFi: Atrae_guest
   - ローカルアカウント名は変更しない
        ↓
3. OneLogin → LastPass → Gmail サインイン
        ↓
4. Atrae Self-Service (Jamf Pro) が業務アプリを自動配布
   ※ Complete になるまで待つ
        ↓
5. dotfiles bootstrap（本リポジトリ）
   - chezmoi.toml を AirDrop で旧 Mac から受け取る
   - bootstrap.sh 実行
        ↓
6. 開発環境の機微情報を復元
   - SSH / AWS / GitHub Packages PAT
        ↓
7. macOS defaults を OPT-IN で適用（hotcorners 除外）
        ↓
8. 動作確認 → Slack の Security Project に「セットアップ完了」報告
        ↓
9. 旧 Mac の初期化（Security Project の確認後のみ）
```

## 1. 新 Mac の初期セットアップ

公式マニュアル (`macbook-18854be6e7ad804aa6ede2c0b8fb1ce7` 系) の指示に従う。
要点だけ抜粋:

- [ ] **「新しい Mac として設定」** を選ぶ（Migration Assistant は禁止）
- [ ] 言語: 日本語 / 地域: 日本
- [ ] WiFi: `Atrae_guest`（オフィスで実施する場合）
- [ ] **ローカルアカウント名を変更しない**
  - `~/.local/share/chezmoi` 内の template 化されたパス（`{{ .chezmoi.homeDir }}`）が前提とする
  - 既存運用名（例: `toshihirokato`）と一致させる
- [ ] FileVault は MDM の指示通り
- [ ] Apple ID は個人のものでログイン（業務利用ポリシーに従う）

## 2. SSO ログイン（OneLogin → LastPass → Gmail）

この順番が **Atrae の正式手順**。dotfiles 投入前に済ませる:

- [ ] **OneLogin**
- [ ] **LastPass**（master password 必須。ここから先の機微情報がここに入っている）
- [ ] **Gmail / Google Workspace**

## 3. Atrae Self-Service の自動配布を待つ

Jamf Pro の管理対象 Mac として登録されると、**Atrae Self-Service が自動起動**して業務アプリが配布される。

- [ ] Atrae Self-Service が起動していることを確認
- [ ] 配布完了まで待つ（**ここで bootstrap.sh を走らせると brew と衝突する可能性**）
- [ ] 自動配布されるはず:
  - [ ] Netskope Client（SASE）
  - [ ] Netskope Endpoint DLP
  - [ ] SentinelOne（EDR）
  - [ ] AWS VPN Client（社内固有 .ovpn 入り）
- [ ] 任意配布（Self-Service から手動インストール）:
  - [ ] Amazon Q
- [ ] 不足があれば **Slack の Security Project に依頼**

## 4. dotfiles bootstrap（chezmoi）

Self-Service が Complete になってから実行。

```bash
# 旧 Mac から AirDrop で受け取った chezmoi.toml を配置
mkdir -p ~/.config/chezmoi
mv ~/Downloads/chezmoi.toml ~/.config/chezmoi/chezmoi.toml

# bootstrap 実行
curl -fsSL https://raw.githubusercontent.com/toshihiro-kato/dotfiles/main/scripts/bootstrap.sh | bash
```

詳細とトラブルシュートは `docs/MIGRATION.md` の 2 章を参照。

## 5. 機微情報の復元（LastPass から）

`docs/SECRETS.md` も併読。会社 Mac で必要なもの:

- [ ] SSH 鍵 (`~/.ssh/id_ed25519`) → `chmod 600` + `ssh-add --apple-use-keychain`
- [ ] AWS 認証情報 (`~/.aws/credentials`) → `chmod 600`
- [ ] `gh auth login`
- [ ] GitHub Packages PAT: `set -Ux GITHUB_PACKAGES_TOKEN ghp_xxxxx`
- [ ] 社内 PyPI プロキシ: `~/.config/uv/uv.toml` / `~/.config/pip/pip.conf` を LastPass から復元

## 6. macOS defaults 適用（OPT-IN、hotcorners 除外）

会社 Mac は Jamf Pro の MDM プロファイルが優先される。
**hotcorners は MDM が右下=ロックを固定するためスキップ** する:

```bash
bash ~/.local/share/chezmoi/scripts/macos/all.sh --apply --skip hotcorners
```

右下を Desktop にしたい等の要望があれば、Slack の Security Project にプロファイル変更を依頼する。

## 7. アクセシビリティ / Screen Recording 許可

`docs/MIGRATION.md` 7 章のチェックリストをそのまま使う。
Karabiner / AeroSpace / Raycast / Homerow / CleanShot X など、初回起動時にプロンプトが出るので System Settings から許可。

## 8. 動作確認

```bash
fish --version
mise current
gh auth status
ghq list
aws sts get-caller-identity --profile <profile>
```

業務に必要な最低限が動けば OK。

## 9. Slack の Security Project に完了報告

**これが Atrae の正式な完了基準**。
- [ ] Slack で Security Project に「新 Mac セットアップ完了、旧 Mac の初期化に進んでよいか」を投稿
- [ ] 確認後にのみ旧 Mac の初期化に進む

## 10. 旧 Mac の初期化と返却

公式マニュアル (`macbook-18854be6e7ad804aa6ede2c0b8fb1ce7`) に従う。

- [ ] Time Machine フルバックアップ（個人保険）
- [ ] Apple ID サインアウト / Find My Mac オフ
- [ ] iCloud / iMessage / FaceTime / Notes など Apple サービスをサインアウト
- [ ] 「すべてのコンテンツと設定を消去」
- [ ] 情シスの返却指示に従う

## 個人 Mac との差分まとめ

| 項目 | 個人 Mac | 会社 Mac (Atrae) |
|------|---------|----------------|
| ログイン主体 | Apple ID + LastPass | OneLogin → LastPass → Gmail |
| 業務アプリ配布 | 手動 | Atrae Self-Service が自動 |
| Hot corners 右下 | dotfiles で Desktop | MDM がロック画面を強制 |
| `all.sh` 推奨実行 | `--apply` | `--apply --skip hotcorners` |
| 完了基準 | 任意 | Slack Security Project への報告 |
| 旧 Mac 初期化 | 任意のタイミング | Security Project の確認後のみ |
| ローカルアカウント名 | 自由 | 変更禁止（既存名維持） |
