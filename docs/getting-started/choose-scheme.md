# 選擇方案

本方案提供三種配置，滿足不同使用需求。安裝前請先選定適合的 GitHub 分支下載網址。

## 基本配置

| 方案 | 說明 | 下載網址 |
|------|------|----------|
| **中文輸入** | 純中文輸入，不含英文詞庫，可中英混輸 | `https://codeload.github.com/ryanwuson/rime-liur-ios/zip/refs/heads/main` |
| **中文輸入 + 英文詞庫** | 包含英文詞庫，支援英文自動補全，可中英混輸 | `https://codeload.github.com/ryanwuson/rime-liur-ios/zip/refs/heads/english` |
| **中文輸入 + 屏蔽無效鍵** | 純中文輸入 + 屏蔽無效按鍵，**不可**中英混輸 | `https://codeload.github.com/ryanwuson/rime-liur-ios/zip/refs/heads/main-block` |

## 舊版曾有的第四種方案（已下架）

若你曾依舊版使用指南安裝過 **「中文輸入 + 英文詞庫 + 屏蔽無效鍵」**（`english-block` 分支），會發現新版只剩上表三種——這是刻意的調整，不是漏寫。

| 舊版方案 | 說明 |
|--------|------|
| **中文輸入 + 英文詞庫 + 屏蔽無效鍵** | 英文詞庫 + 屏蔽無效按鍵；英文字母多於 5 字可中英混輸 |

**為何下架：** 中文與英文詞庫混輸疊加，屏蔽體驗效果有限，故不再維護 `english-block` 分支。

**請改選：**

| 你的需求 | 建議方案 |
|----------|----------|
| 要英文詞庫、中英混輸 | **中文輸入 + 英文詞庫** |
| 要屏蔽無效鍵、純中文輸入 | **中文輸入 + 屏蔽無效鍵** |

## 關於「屏蔽無效鍵」

方案中所稱之**「屏蔽無效鍵」**，是讓你無法按出無效鍵（例如按完 `ab` 後無法按 `c`），但**視覺上無法讓 c 鍵變淡**──這是元書輸入法尚未支援的功能。詳見 [無效鍵屏蔽·視覺限制](../features/block-invalid-keys.md#視覺限制)。

## 皮膚主題

鍵盤外觀可透過 [蝦米輸入法皮膚設計器](https://ggininder.work/r/Ryan) 自訂。設計器可調整佈局、工具列、配色、字體等；完整操作請見 [設計器說明](https://ryanwuson.github.io/rime-liur-ios-new-skin/guide/#/)。

方案裝好後，請依 [皮膚：手機安裝](../skin/install-on-phone.md) 將 `.cskin` 匯入元書輸入法使用。

## 下一步

- [刪除舊方案（升級前）](getting-started/remove-old-scheme.md)（曾安裝舊版者）
- [手機安裝方案](getting-started/install-scheme-phone.md)
- [電腦安裝方案](getting-started/install-scheme-pc.md)
