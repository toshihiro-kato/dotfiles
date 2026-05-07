#!/bin/bash
# Claude Code ステータスライン
# 表示項目: モデル | ディレクトリ | ブランチ | トークン | コスト | 編集情報

# stdin から JSON を読み込む
input=$(cat)

# Nerd Font アイコン (printf でUTF-8バイト列を出力)
ICON_MODEL=$(printf "\xf3\xb0\x9a\xa9")      # 󰚩 アシスタント
ICON_DIR=$(printf "\xef\x90\x93")            #  ディレクトリ
ICON_BRANCH=$(printf "\xef\x90\xa6")         #  Git ブランチ
ICON_TOKEN=$(printf "\xef\x83\xa4")          #  トークン/パフォーマンス
ICON_COST=$(printf "\xef\x85\x95")           #  通貨
ICON_EDIT=$(printf "\xef\x81\x93")           #  編集

# JSON から値を抽出
MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "."')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUTPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
USED_PERCENT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')

# ディレクトリ名を短縮（最後のコンポーネントのみ）
DIR_NAME=$(basename "$CURRENT_DIR")

# Git ブランチを取得
GIT_BRANCH=""
if cd "$CURRENT_DIR" 2>/dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -z "$BRANCH" ]; then
        # detached HEAD の場合はコミットハッシュを表示
        BRANCH=$(git rev-parse --short HEAD 2>/dev/null)
    fi
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH="$BRANCH"
    fi
fi

# 編集済みファイル数を取得（git の変更ファイル数）
EDITED_FILES=0
if cd "$CURRENT_DIR" 2>/dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
    EDITED_FILES=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    STAGED_FILES=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    EDITED_FILES=$((EDITED_FILES + STAGED_FILES))
fi

# トークン数をフォーマット（K単位）
format_tokens() {
    local tokens=$1
    if [ "$tokens" -ge 1000 ]; then
        echo "$(echo "scale=1; $tokens / 1000" | bc)K"
    else
        echo "$tokens"
    fi
}

INPUT_FORMATTED=$(format_tokens "$INPUT_TOKENS")
OUTPUT_FORMATTED=$(format_tokens "$OUTPUT_TOKENS")

# コストをフォーマット
COST_FORMATTED=$(printf "%.3f" "$COST")

# コンテキスト使用率を整数に丸める
USED_PERCENT_INT=$(printf "%.0f" "$USED_PERCENT")

# ステータスラインを構築
STATUS=""
STATUS+="$ICON_MODEL $MODEL"
STATUS+=" | $ICON_DIR $DIR_NAME"

if [ -n "$GIT_BRANCH" ]; then
    STATUS+=" | $ICON_BRANCH $GIT_BRANCH"
fi

STATUS+=" | $ICON_TOKEN ${INPUT_FORMATTED}/${OUTPUT_FORMATTED} (${USED_PERCENT_INT}%)"
STATUS+=" | $ICON_COST \$${COST_FORMATTED}"
STATUS+=" | $ICON_EDIT ${EDITED_FILES}f +${LINES_ADDED}/-${LINES_REMOVED}"

echo "$STATUS"
