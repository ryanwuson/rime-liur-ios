# Rime Git 維護指令大全 (Cheatsheet)

這份文件包含您日後維護 `rime-liur-ios` 專案時最常用的指令。
建議您將此檔案存在電腦中方便查詢。

**預設工作目錄**：`/Users/ryan/Desktop/rime-liur-ios`

---

## 1. 基礎操作

### 檢查現在在哪個分支
```bash
git branch
# 有 * 號的就是目前的分支
```

### 切換分支
```bash
# 切換到旗艦版 (英文+屏蔽)
git checkout english-block

# 切換到純中文版
git checkout main
```

### 查詢狀態 (看改了什麼檔)
```bash
git status
```

---

## 2. 日常修改與備份 (Commit)

假設您在 `english-block` 分支修改了某些檔案，想要儲存進度：

```bash
# 1. 確保自己在對的分支
git checkout english-block

# 2. 加入所有修改
git add .

# 3. 提交 (引號內寫這次改了什麼)
git commit -m "修正 liu_data.lua 的錯誤"

# 4. 上傳到 GitHub
git push
```

---

## 3. 同步修改 (最重要！)

**情境**：您在 `english-block` 修改了一個 **共用檔案** (例如 `lua/liu_data.lua`)，希望其他 3 個版本也一起更新。

**核心指令**：`git checkout [來源分支] -- [檔案路徑]`

### 操作步驟：
```bash
# 1. 先在來源分支 (english-block) 修好並 Commit (同上)

# 2. 切換到目標分支 (例如 main)
git checkout main

# 3. 從來源分支「抓」那個檔案過來 (覆蓋)
git checkout english-block -- lua/liu_data.lua
# 如果有多個檔案，可以列在後面，或用 * 通配符

# 4. 提交變更
git commit -m "同步 liu_data.lua"

# 5. 重複步驟 2-4 對其他分支 (main-block, english) 做一樣的事
git checkout main-block
git checkout english-block -- lua/liu_data.lua
git commit -m "同步 liu_data.lua"

# ...做完所有分支...

# 6. 一次全部上傳
git push --all origin
```

---

## 4. 獨特檔案修改 (不要同步！)

**注意**：以下檔案在每個分支內容不同，**請勿同步**，必須個別修改：
*   `liur.schema.yaml` (因為開關設定不同)
*   `rime.lua` (因為載入的 Processor 不同)

**正確做法**：
切換到該分支 -> 修改 -> Commit -> 切換到下一個分支 -> 修改 -> Commit。

---

## 5. 進階：一次看所有分支的差異
如果您想確認 `main` 和 `english-block` 的某個檔案差在哪：
```bash
git diff main english-block -- lua/liu_data.lua
```
