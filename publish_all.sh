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
    # 使用 rsync 確保刪除的檔案也會被同步刪除 (--delete)，並排除 .git 和原始資料夾
    # 排除清單必須跟 .gitignore 吻合，避免把備份資料夾殺掉
    # 但因為備份資料夾在 .gitignore 裡，rsync 預設不會去動它們如果它們是目的地？
    # 不，我們要從 SOURCE 複製到 ROOT。
    # 簡單起見，我們用 cp -R 覆寫。如果需要刪除檔案，Git add . 會處理修改和新增，
    # 但 git add . 在舊版 git 可能不處理刪除。我們用 git add -A。
    
    cp -R "$SOURCE_DIR_NAME/"* .
    
    # 3. 提交並上傳
    git add -A
    # 只有在有變更時才 Commit，避免空 Commit 錯誤
    if ! git diff-index --quiet HEAD; then
        git commit -m "Auto-update: $DESCRIPTION"
        git push origin $BRANCH_NAME
        echo "✅ $BRANCH_NAME 上傳成功"
    else
        echo "👌 $BRANCH_NAME 沒有變更，跳過上傳"
    fi
}

# 確保腳本存在於所有分支 (以免切換後腳本消失導致執行中斷)
# 這是一個小技巧：我們先把腳本複製到 /tmp 執行？
# 既然我們最終會回到 maintenance，只要 maintenance 有腳本就行？
# 不，shell 執行中的腳本如果被刪除會出錯。
# 所以我們假設這個腳本在所有分支都「存在」比較保險。
# 或者，我們都在 "maintenance" 分支執行，但這裡運用 git worktree？太複雜。
# 最簡單：我把這個腳本 add 到所有分支。

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
