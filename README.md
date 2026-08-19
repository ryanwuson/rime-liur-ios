# iOS 元書輸入法 - 蝦米方案

基於元書輸入法的蝦米輸入方案，提供多種配置選項；鍵盤外觀可透過皮膚設計器自訂。

## 主要特色

- 🚀 **完整蝦米功能**：標準字碼、簡碼、VRSF 選字等
- 🎨 **自訂皮膚**：[蝦米輸入法皮膚設計器](https://ggininder.work/r/Ryan) 調整佈局、工具列、配色；[操作說明](https://ryanwuson.github.io/rime-liur-ios-new-skin/guide/#/)
- 🎵 **注音／拼音**：獨立注音、拼音鍵盤，直接打字選字；單字候選附蝦米字碼，並可隨附 Emoji
- 📝 **智慧造詞**：臨時造詞、自訂詞庫（「屏蔽無效鍵」方案不適用）；組字中下滑 Backspace 可刪目前詞條／詞組記憶
- 🔍 **查詢模式**：讀音查詢、同音選字
- 🎯 **快打／強制快打**：`,,sp` 提示簡碼；`,,sf` 可續打簡碼出字（需開啟候選 Comment）
- 🔤 **符號與變體**：分類符號、變體英數、字母變化形
- 🌐 **英文詞庫**（english 分支）：自動補全、大小寫轉換
- 🛡️ **無效鍵屏蔽**（main-block 分支）：避免按出無效鍵
- 🧮 **計算機**、聯想字等延伸功能

## 方案配置

提供三種配置（詳見 [使用說明·選擇方案](https://ryanwuson.github.io/rime-liur-ios/#/getting-started/choose-scheme)）：

| 方案 | 說明 |
|------|------|
| **中文輸入**（main） | 純中文，可中英混輸 |
| **中文輸入 + 英文詞庫**（english） | 含英文詞庫，可中英混輸 |
| **中文輸入 + 屏蔽無效鍵**（main-block） | 純中文 + 屏蔽無效鍵，**不可**中英混輸 |

從舊版升級者，請先 [刪除舊方案](https://ryanwuson.github.io/rime-liur-ios/#/getting-started/remove-old-scheme) 再安裝；快打常駐、聯想字等自訂需 [重新設定](https://ryanwuson.github.io/rime-liur-ios/#/getting-started/scheme-switches)。

## 鍵盤切換

切到注音／拼音鍵盤即進入獨立方案。詳見 [鍵盤佈局](https://ryanwuson.github.io/rime-liur-ios/#/daily-use/keyboard-layout)、[注音輸入](https://ryanwuson.github.io/rime-liur-ios/#/features/bopomofo)、[拼音輸入](https://ryanwuson.github.io/rime-liur-ios/#/features/pinyin)。

| 切到 | 方式 |
|------|------|
| 注音鍵盤 | iPhone **Enter 上滑**；iPad **右 Shift 下滑**；工具列「ㄅ」 |
| 拼音鍵盤 | iPad **左 Shift 下滑**；工具列「拼」 |
| 回到蝦米 | iPhone「返回」上滑；iPad「返回」下滑 |

## 安裝方式

### 系統需求

- [元書輸入法](https://apps.apple.com/us/app/%E5%85%83%E4%B9%A6%E8%BE%93%E5%85%A5%E6%B3%95/id6744464701?l=zh-Hant-TW)（iOS 16 或以上）

### 下載方案

- **中文輸入**：`https://codeload.github.com/ryanwuson/rime-liur-ios/zip/refs/heads/main`
- **中文輸入 + 英文詞庫**：`https://codeload.github.com/ryanwuson/rime-liur-ios/zip/refs/heads/english`
- **中文輸入 + 屏蔽無效鍵**：`https://codeload.github.com/ryanwuson/rime-liur-ios/zip/refs/heads/main-block`

手機下載、電腦 Wi‑Fi 傳檔、啟用輸入法等步驟，請見 **[完整使用說明](https://ryanwuson.github.io/rime-liur-ios/)**。

### 安裝皮膚

1. 在設計器 [ggininder.work/r/Ryan](https://ggininder.work/r/Ryan) 編輯後，導出 `.cskin`
2. 以元書輸入法開啟檔案，長按皮膚主題 → **運行 main.jsonnet**

細節見 [皮膚：手機安裝](https://ryanwuson.github.io/rime-liur-ios/#/skin/install-on-phone)。

## 文件資源

📖 **[完整使用說明](https://ryanwuson.github.io/rime-liur-ios/)** — 安裝入門、手勢、輸入功能、更新紀錄  
🎨 **[皮膚設計器說明](https://ryanwuson.github.io/rime-liur-ios-new-skin/guide/#/)** — 佈局、工具列、配色與導出

## 授權

本專案基於開源授權發佈，歡迎使用和改進。

## 致謝

感謝所有為元書輸入法及蝦米輸入方案發展做出貢獻的開發者、使用者及測試者。

---

**在 iOS 上享受流暢的蝦米輸入體驗！** 🦐⌨️
