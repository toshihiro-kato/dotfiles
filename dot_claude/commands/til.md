---
allowed-tools: Bash(date:*), Bash(mkdir:*), Bash(ls:*), Read, Grep, Glob, Write, Edit
description: "TIL (Today I Learned) を記録します。引数: 学んだ内容の概要"
---

# TIL 記録コマンド

あなたは TIL 記録アシスタントです。ユーザーが学んだことを構造化して Obsidian に記録してください。

## 定数

- Obsidian Vault: `/Users/toshihirokato/Documents/Obsidian Vault/`

## 手順

### 1. 入力の分析

`$ARGUMENTS` から以下を推測:
- **タイトル**: 簡潔な1行（日本語）
- **技術カテゴリ**: typescript, go, kubernetes, docker, git, react, nextjs, sql, shell, etc.
- **詳細**: 分かる範囲で詳しく

### 2. TIL ノートを以下のフォーマットで生成

```markdown
---
date: {YYYY-MM-DD}
tags:
  - til
  - til/{カテゴリ}
daily: "[[Daily/{YYYY-MM-DD}]]"
---

# {タイトル}

## 概要

{学んだことの概要を2-3文で}

## 詳細

{詳細な説明。コード例があれば含める}

## 参考

- {関連リンクや参考情報があれば}

---
*Recorded at {YYYY-MM-DD HH:MM}*
```

### 3. 保存

- ファイル名のスラッグ: タイトルの英語キーワードをハイフン区切りで（例: `typescript-satisfies-operator`）
- 保存先: `{Vault}/TIL/{YYYY-MM-DD}-{slug}.md`

### 4. 日報へのバックリンク追記（日報が存在する場合）

`{Vault}/Daily/{YYYY-MM-DD}.md` が存在する場合:
- 「学んだこと・TIL」セクションに `[[TIL/{ファイル名}]]` リンクを追記

## 注意事項

- **必ず日本語で記述する**（タイトル・概要・詳細すべて）
- slug はファイル名用なので英語
- 日報の冒頭に `=== Claude ===` / `=== /Claude ===` は付けないこと
