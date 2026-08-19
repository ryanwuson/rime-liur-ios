#!/bin/bash
# 繼承發佈：maintenance（共用檔 + docs + _variants）→ main / main-block / english
# 必須在乾淨的 maintenance 上執行（先 commit 工作區）。
# 用法：在 repo 根目錄  ./publish_all.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

require_maintenance() {
    local current
    current="$(git branch --show-current)"
    if [ "$current" != "maintenance" ]; then
        echo "錯誤：請在 maintenance 分支執行此腳本（目前是 ${current}）。"
        exit 1
    fi
}

require_clean() {
    if ! git diff --quiet || ! git diff --cached --quiet \
        || [ -n "$(git ls-files --others --exclude-standard)" ]; then
        echo "錯誤：工作區不乾淨。請先在 maintenance 提交（或 stash），再發佈。"
        echo "（未提交就跑會被 checkout 清掉。）"
        git status -sb
        exit 1
    fi
}

require_variants() {
    local dir
    for dir in _variants/main _variants/main-block _variants/english; do
        if [ ! -f "$dir/rime.lua" ] || [ ! -f "$dir/liur.schema.yaml" ]; then
            echo "錯誤：缺少 ${dir}/rime.lua 或 liur.schema.yaml"
            exit 1
        fi
    done
}

publish_branch() {
    local BRANCH_NAME="$1"
    local DESCRIPTION="$2"
    local VARIANT_DIR="_variants/${BRANCH_NAME}"

    echo "------------------------------------------------------"
    echo "正在處理: ${DESCRIPTION} (${BRANCH_NAME})"

    git checkout "$BRANCH_NAME"
    if [ "$(git branch --show-current)" != "$BRANCH_NAME" ]; then
        echo "錯誤：無法切換到 ${BRANCH_NAME}，停止以保護 maintenance"
        exit 1
    fi

    git checkout maintenance -- .

    cp "${VARIANT_DIR}/rime.lua" .
    cp "${VARIANT_DIR}/liur.schema.yaml" .
    echo "   -> 已用 ${VARIANT_DIR} 覆蓋 rime.lua 和 liur.schema.yaml"

    git add -A
    git rm -r --cached _variants publish_all.sh docs/ 2>/dev/null || true
    git rm -rf --cached librime-predict/ 2>/dev/null || true

    if git diff --cached --quiet; then
        echo "${BRANCH_NAME} 沒有變更，跳過上傳"
    else
        git commit -m "Auto-update: ${DESCRIPTION}"
        git push origin "$BRANCH_NAME"
        echo "${BRANCH_NAME} 上傳成功"
    fi
}

require_maintenance
require_variants
require_clean

echo "開始發佈（繼承模式）"
echo "--- 先推 maintenance（含 docs/，GitHub Pages 用這支）---"
git push origin maintenance

publish_branch "main" "純中文版"
publish_branch "main-block" "純中文+屏蔽版"
publish_branch "english" "英文版"

echo "------------------------------------------------------"
# 發佈分支會 git rm --cached docs/，檔案留在工作區成未追蹤；
# 不加 -f 回 maintenance 會被「會覆寫未追蹤檔」擋住。
git checkout -f maintenance
echo "全部完成，已回到 maintenance。"
