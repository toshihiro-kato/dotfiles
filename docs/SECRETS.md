# 機微情報の取り扱い

このリポジトリは **Public** なので、以下を **絶対にコミットしない**。

## ❌ 絶対にコミットしてはいけないもの

| 種類 | パス | 推奨保管先 |
|------|------|-----------|
| SSH 秘密鍵 | `~/.ssh/id_*`（`.pub` 以外） | 1Password (Secure Note) |
| GPG 秘密鍵 | `~/.gnupg/private-keys-*` | 1Password |
| AWS 認証情報 | `~/.aws/credentials` | 1Password |
| GitHub PAT (Classic) | `ghp_*` | 1Password |
| GitHub PAT (Fine-grained) | `github_pat_*` | 1Password |
| OpenAI / Anthropic API Key | `sk-*` / `sk-ant-*` | 1Password |
| `.netrc` | `~/.netrc` | 1Password |
| `.git-credentials` | `~/.git-credentials` | 削除して osxkeychain 使用 |
| Google IME 辞書 (両方セット) | `~/Library/Application Support/Google/JapaneseInput/.history.db` + `.encrypt_key.db` | TSV エクスポートして 1Password |
| ライセンスキー | アプリ plist 内の `activationKey` 等 | 1Password |
| `.npmrc` の Token | 平文コミット禁止 → 環境変数化 | 1Password |
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

将来的には [1Password CLI 連携](https://developer.1password.com/docs/cli/) で:

```fish
set -gx GITHUB_PACKAGES_TOKEN (op read "op://Private/GitHub PAT (npm)/credential")
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

### AWS

- `~/.aws/config` は dotfiles に含めて OK（プロファイル名・リージョン）
- `~/.aws/credentials` は **絶対にコミットしない**
- `aws-vault` を使うと credentials は Keychain に保存され、ファイルから消える ✨

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

dotfiles 管理から除外（手動再生成）:

| パス | 内容 | 復元方法 |
|------|------|----------|
| `~/.config/uv/uv.toml` | 社内 PyPI プロキシ | `docs/MIGRATION.md` 4 章の手順で再生成 |
| `~/.config/pip/pip.conf` | 同上 | 同上 |

## 旧Macで PAT を発見した実例（2026/05）

- `.gitconfig` に `ghp_YcO1...` が `[url ...]` で埋め込まれていた → 既に Expired、ファイルから削除済み
- `.npmrc` に `ghp_qhsf...` が `_authToken` で平文 → 既に Expired、`${GITHUB_PACKAGES_TOKEN}` 化済み

両方とも当時は有効期限切れだったため漏洩リスクなし。
