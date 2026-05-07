# 機微情報の取り扱い

このリポジトリは **Public** なので、以下を **絶対にコミットしない**。

## ❌ 絶対にコミットしてはいけないもの

| 種類 | パス | 推奨保管先 |
|------|------|-----------|
| SSH 秘密鍵 | `~/.ssh/id_*`（`.pub` 以外） | LastPass (Secure Note) |
| GPG 秘密鍵 | `~/.gnupg/private-keys-*` | LastPass |
| AWS 認証情報 | `~/.aws/credentials` | LastPass |
| GitHub PAT (Classic) | `ghp_*` | LastPass |
| GitHub PAT (Fine-grained) | `github_pat_*` | LastPass |
| OpenAI / Anthropic API Key | `sk-*` / `sk-ant-*` | LastPass |
| `.netrc` | `~/.netrc` | LastPass |
| `.git-credentials` | `~/.git-credentials` | 削除して osxkeychain 使用 |
| Google IME 辞書 (両方セット) | `~/Library/Application Support/Google/JapaneseInput/.history.db` + `.encrypt_key.db` | TSV エクスポートして LastPass |
| ライセンスキー | アプリ plist 内の `activationKey` 等 | LastPass |
| `.npmrc` の Token | 平文コミット禁止 → 環境変数化 | LastPass |
| `~/.claude.json` | 認証情報含む | 自動生成、コミット不要 |

## ✅ チェック方法

chezmoi に追加する前にスキャン:

```bash
# 標準: chezmoi 自身の secret detection
chezmoi add <file>   # PAT 等を含むと中断される

# git push 前のフックに gitleaks を仕込むのも有効
brew install gitleaks
gitleaks detect --source ~/.local/share/chezmoi
```

## 🔐 安全な認証フロー

### Git / GitHub

- Git の `credential.helper` は `osxkeychain`（既に設定済み）
- `gh auth login` で gh CLI が Keychain に保存（既に運用中）
- PAT を `.gitconfig` の `[url ...]` に埋め込まない

### npm / pnpm（GitHub Packages）

`.npmrc` 内で `${GITHUB_PACKAGES_TOKEN}` を参照:

```ini
//npm.pkg.github.com/:_authToken=${GITHUB_PACKAGES_TOKEN}
```

fish の universal variable に保存:

```fish
set -Ux GITHUB_PACKAGES_TOKEN ghp_xxxxx
```

将来的には LastPass CLI（[lpass](https://github.com/lastpass/lastpass-cli)）連携で:

```fish
set -gx GITHUB_PACKAGES_TOKEN (lpass show --password "GitHub PAT (npm)")
```

### SSH

- `id_ed25519` (work) と `id_ed25519_personal` (personal) を `~/.ssh/config` で host 別に使い分け
- macOS の Keychain と統合: `ssh-add --apple-use-keychain`
- `~/.ssh/config` は dotfiles に含めて OK（ホスト名やユーザー名のみ、秘密鍵は別）

```ssh-config
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  UseKeychain yes
  AddKeysToAgent yes
```

#### 新Macでの復元手順

```bash
# 1) LastPass の各 Secure Note の Private Key 部分を貼り付け
mkdir -p ~/.ssh
$EDITOR ~/.ssh/id_ed25519           # work 用
$EDITOR ~/.ssh/id_ed25519_personal  # personal 用

# 2) 公開鍵も貼り付け（GitHub 比較用、なくてもログインはできる）
$EDITOR ~/.ssh/id_ed25519.pub
$EDITOR ~/.ssh/id_ed25519_personal.pub

# 3) ~/.ssh/config 復元（LastPass の "SSH config" Note から）
$EDITOR ~/.ssh/config

# 4) パーミッション
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519 ~/.ssh/id_ed25519_personal ~/.ssh/config
chmod 644 ~/.ssh/id_ed25519.pub ~/.ssh/id_ed25519_personal.pub

# 5) Keychain 統合 + agent に追加
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_personal

# 6) 動作確認
ssh -T git@github.com              # → "Hi <work-account>! ..."
ssh -T git@github.com-personal     # → "Hi <personal-account>! ..."
```

### AWS

- `~/.aws/config` は dotfiles に含めて OK（プロファイル名・リージョン）
- `~/.aws/credentials` は **絶対にコミットしない**
- `aws-vault` を使うと credentials は Keychain に保存され、ファイルから消える ✨

#### 新Macでの復元手順

```bash
# 1) LastPass の "AWS credentials (~/.aws/credentials)" Note の Content を貼り付け
mkdir -p ~/.aws
$EDITOR ~/.aws/credentials
chmod 600 ~/.aws/credentials

# 2) 動作確認
aws sts get-caller-identity --profile default
aws sts get-caller-identity --profile dev

# 3) SSO 系プロファイルはトークン再取得（credentials には含まれない）
aws sso login --profile wevox_develop
```

## 🚨 もし誤って commit/push してしまったら

1. **即 revoke**（GitHub.com の Settings → Tokens で Delete）
2. git 履歴から除去:
   ```bash
   # BFG Repo-Cleaner（推奨）
   brew install bfg
   bfg --replace-text passwords.txt
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive
   git push --force
   ```
3. 過去のコミットに残っているとリスクなので、できるだけ早く対応

## 会社固有値の取り扱い

Public リポなので、Atrae 社内識別子（AWS Account ID, SSO URL, GCP Project ID 等）も載せない。
chezmoi の template 機能で `~/.config/chezmoi/chezmoi.toml`（**git 管理外**）に値を保管し、
ファイルは `{{ .var_name }}` 参照に書き換える。

template 化済みファイル:

| ファイル | 参照変数 |
|---------|----------|
| `dot_aws/private_config.tmpl` | `aws_dev_account_id`, `aws_prod_account_id`, `aws_sso_start_url`, `aws_sso_region` |
| `dot_config/private_fish/config.fish.tmpl` | `gcp_project` |
| `private_dot_npmrc.tmpl` | `npm_work_scope`, `npm_proxy_registry` |
| `private_dot_bunfig.toml.tmpl` | `npm_proxy_registry` |
| `private_dot_yarnrc.yml.tmpl` | `npm_proxy_registry` |

dotfiles 管理から除外（手動再生成）:

| パス | 内容 | 復元方法 |
|------|------|----------|
| `~/.config/uv/uv.toml` | 社内 PyPI プロキシ | `docs/MIGRATION.md` 4 章の手順で再生成 |
| `~/.config/pip/pip.conf` | 同上 | 同上 |

## 📦 LastPass バックアップ記録

| 項目 | LastPass Note 名 | 最終更新 | 備考 |
|------|----------------|---------|------|
| SSH 鍵 (work) | `SSH key: id_ed25519 (work)` | 2026-05-07 | fingerprint `SHA256:nIaFIQqvjlGklQeWU71R0M6X9a9ITqH5NIuIPTvwpUU` |
| SSH 鍵 (personal) | `SSH key: id_ed25519_personal` | 2026-05-07 | fingerprint `SHA256:r1VjXTIYZaUdmWbA5uWcA60w1T7GoD//OVFYHIsIM2I` |
| `~/.ssh/config` | `SSH config (~/.ssh/config)` | 2026-05-07 | host alias `github.com-personal` 定義のみ |
| chezmoi config (work) | `chezmoi config (work)` | 2026-05-07 | AirDrop が主、これは保険。588 bytes / 14 行 |
| AWS credentials | `AWS credentials (~/.aws/credentials)` | 2026-05-07 | profiles: `default-long-term`, `dev`, `default`（SSO は別途 `aws sso login`） |
| ライセンスキー | `App License Keys (master)` | 2026-05-07 | CleanShot X / Bartender 5 / Homerow を自動取得済。Affinity / Eagle / DemoPro / QuickShade は移行時に追記 |
| Google IME 辞書 (TSV) | `Google IME user dictionary (TSV)` | 2026-05-07 | 14 行（個人情報含むため厳重管理）。実体ファイル `~/Downloads/google-ime-userdict.txt` |
| Raycast .rayconfig パスワード | `Raycast .rayconfig (export password)` | 2026-05-07 | ファイル本体は iCloud Drive `~/Library/Mobile Documents/com~apple~CloudDocs/Setup/raycast.rayconfig` (2.7 MB)。LastPass には復号パスワードのみ |
| Raycast post-import checklist | `Raycast settings (manual fallback)` | 2026-05-07 | `.rayconfig` で復元されない権限付与・Hotkey 再有効化・アカウント再ログインの手順 |

鍵を更新したら本テーブルの「最終更新」も更新する（ローテーション忘れ防止）。

## 旧Macで PAT を発見した実例（2026/05）

- `.gitconfig` に `ghp_YcO1...` が `[url ...]` で埋め込まれていた → 既に Expired、ファイルから削除済み
- `.npmrc` に `ghp_qhsf...` が `_authToken` で平文 → 既に Expired、`${GITHUB_PACKAGES_TOKEN}` 化済み

両方とも当時は有効期限切れだったため漏洩リスクなし。
