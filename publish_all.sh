#!/bin/bash

# Rime 自動發布腳本 (Inheritance Mode)
# 邏輯： Root (Common) + _variants (Override) -> Branch

REPO_ROOT="$(pwd)"
echo "🚀 開始自動發布流程 (繼承模式)..."

# 定義函數：發布單一分支
publish_branch() {
    BRANCH_NAME=$1
    VARIANT_DIR="_variants/$BRANCH_NAME"
    DESCRIPTION=$2

    echo "------------------------------------------------------"
    echo "正在處理: $DESCRIPTION ($BRANCH_NAME)"
    
    # 1. 切換到該分支
    git checkout $BRANCH_NAME
    
    # 2. 同步共用檔案
    # 把 maintenance (共用區) 的所有檔案倒過來覆蓋目前分支
    git checkout maintenance -- .
    
    # 3. 覆蓋變體特有的檔案 (Override)
    # 從 _variants 對應資料夾複製出來覆蓋根目錄
    if [ -d "$VARIANT_DIR" ]; then
        cp "$VARIANT_DIR/rime.lua" . 2>/dev/null || true
        cp "$VARIANT_DIR/liur.schema.yaml" . 2>/dev/null || true
        echo "   -> 已依照變體設定覆蓋 rime.lua 和 liur.schema.yaml"
    else
        echo "⚠️ 警告：找不到變體資料夾 $VARIANT_DIR"
    fi
    
    # 4. 提交並上傳
    git add -A
    
    # 4.5 從索引中移除不應該發布的工具 (由於 .gitignore 有寫，add -A 不會抓，但為了保險起見再清一次)
    git rm -r --cached _variants publish_all.sh 2>/dev/null || true

    if ! git diff-index --quiet HEAD; then
        git commit -m "Auto-update: $DESCRIPTION"
        git push origin $BRANCH_NAME
        echo "✅ $BRANCH_NAME 上傳成功"
    else
        echo "👌 $BRANCH_NAME 沒有變更，跳過上傳"
    fi
}

# 確保在 maintenance 分支執行
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "maintenance" ]; then
    echo "❌ 錯誤：請在 maintenance 分支執行此腳本。"
    exit 1
fi

# 執行 4 個分支的發布
publish_branch "main" "純中文版"
publish_branch "main-block" "純中文+屏蔽版"
publish_branch "english" "英文版"
publish_branch "english-block" "英文+屏蔽版"

# 最後回到這
echo "------------------------------------------------------"
echo "🎉 全部完成！"
git checkout maintenance
