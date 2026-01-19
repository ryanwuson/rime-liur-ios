#!/bin/bash

# 設定跟目錄和資料夾名稱
# 確保這個腳本在 Repo 根目錄執行
REPO_ROOT="$(pwd)"

echo "🚀 開始自動發布流程..."

# 定義函數：發布單一分支
publish_branch() {
    BRANCH_NAME=$1
    SOURCE_DIR_NAME=$2
    DESCRIPTION=$3

    echo "------------------------------------------------------"
    echo "正在處理: $DESCRIPTION ($BRANCH_NAME)"
    
    # 1. 切換到該分支
    git checkout $BRANCH_NAME
    
    # 2. 同步檔案
    cp -R "$SOURCE_DIR_NAME/"* .
    
    # 3. 提交並上傳
    git add -A
    # 只有在有變更時才 Commit
    if ! git diff-index --quiet HEAD; then
        git commit -m "Auto-update: $DESCRIPTION"
        git push origin $BRANCH_NAME
        echo "✅ $BRANCH_NAME 上傳成功"
    else
        echo "👌 $BRANCH_NAME 沒有變更，跳過上傳"
    fi
}

# 執行 4 個分支的發布
publish_branch "main" "中文輸入" "純中文版"
publish_branch "main-block" "中文輸入+屏蔽無效鍵" "純中文+屏蔽版"
publish_branch "english" "中文輸入+英文詞庫" "英文版"
publish_branch "english-block" "中文輸入+英文詞庫+屏蔽無效鍵" "英文+屏蔽版"

# 最後回到乾淨模式
echo "------------------------------------------------------"
echo "🧹 切換回乾淨模式 (maintenance)..."
git checkout maintenance

echo "🎉 全部完成！您的 GitHub 已經同步更新。"
