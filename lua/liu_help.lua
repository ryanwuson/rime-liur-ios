-- liu_help.lua
-- 按鍵說明（,,h）：顯示主要功能的快捷鍵與引導鍵
--
-- 13（iOS）與 14（桌面）共用同一份清單與排序。
-- 平台不需要的項目用註解屏蔽，不要刪，方便對照維護。
-- 標記：-- iOS 不需要　／　-- 桌面不需要

local M = {}

M.help_items = {
    -- iOS 不需要：無外接鍵盤
    -- "蝦米切換 ▸ Ctrl + '",
    -- "注音切換 ▸ Ctrl + Shift + '",
    -- "Easy English 切換 ▸ Ctrl + ;",
    -- "拼音切換 ▸ Ctrl + Shift + ;",
    "快打提示 ▸ ,,sp",
    "強制快打 ▸ ,,sf",
    -- iOS 不需要：無外接鍵盤
    -- "簡繁切換 ▸ Ctrl + .",
    -- "查碼功能 ▸ Ctrl + /",
    -- iOS 不需要：行內反查已停用，改走獨立鍵盤
    -- "蝦米內注音輸入 ▸ ';",
    -- "蝦米內注音直出 ▸ ';'",
    -- "蝦米內拼音輸入 ▸ ;'",
    -- iOS 不需要：桌面無「同音」鍵，用下一條
    -- "同音選字 ▸ 字尾 + '",
    "同音選字 ▸ 字尾 + ' 或同音鍵",
    "造詞功能 ▸ ;",
    "讀音查詢 ▸ ;;",
    -- iOS 不需要：無外接鍵盤；用下一條 ,,=
    -- "計算機 ▸ Ctrl + = 或 ,,=",
    "計算機 ▸ ,,=",
    -- iOS 不需要：萬用查字在手機端已關閉
    -- "萬用查字 ▸ ,,wc",
    "清除聯想 ▸ ,,clean",
    -- iOS 不需要：無外接鍵盤；請用空白鍵上滑
    -- "擴充字集 ▸ Ctrl + ,",
    -- iOS 不需要：請用符號鍵盤
    -- "符號清單 ▸ `",
    "變體數字 ▸ `' + 01 ~ 50 (單獨)",
    "數字變體 ▸ `/' (連續輸入)",
    "英文變體 ▸ `/ (首字母大寫)",
    "英文變體 ▸ `// (全小寫)",
    "英文變體 ▸ `/// (全大寫)",
    "日期時間 ▸ ``/",
    "字母變化 ▸ `` + a~z",
    -- iOS 不需要：桌面說明網址
    -- "完整說明 ▸ ryanwuson.github.io/rime-liur",
    "完整說明 ▸ https://ryanwuson.github.io/rime-liur-ios/",
}

function M.translator(input, seg, env)
    local context_input = env.engine.context.input
    if context_input ~= ",,h" then return end

    for _, item in ipairs(M.help_items) do
        yield(Candidate("help", seg.start, seg._end, item, ""))
    end
end

return M
