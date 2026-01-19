-- liu_custom_word_filter.lua
-- 排序過濾器：蝦米完整 > 自定詞完整 > 蝦米補字 > 自定詞補全 > 假名 > 擴充 > 英文
--
-- 串流處理策略：
-- 1. 蝦米完整匹配：暫存
-- 2. 自定詞完整匹配(custom)：暫存
-- 3. 蝦米補字：先輸出蝦米完整 + 自定詞完整，再輸出補字
-- 4. 自定詞補全(custom_completion)：暫存到最後輸出（在假名之前）
-- 5. 如果沒有蝦米補字，在迴圈結束後輸出蝦米完整 + 自定詞完整

local common = require("liu_common")
local is_kana = common.is_kana
local is_extended_charset = common.is_extended_charset

local MAX_BUFFER = 30

local function is_ascii_english(text)
    local len = #text
    if len == 0 or string.byte(text, 1) > 127 then return false end
    local has_letter = false
    for i = 1, len do
        local b = string.byte(text, i)
        if b > 126 or b < 32 then return false end
        if not has_letter and ((b >= 65 and b <= 90) or (b >= 97 and b <= 122)) then
            has_letter = true
        end
    end
    return has_letter
end

local function get_cjk_type(text)
    for _, code in utf8.codes(text) do
        if is_extended_charset(code) then return 2 end
        if is_kana(code) then return 1 end
    end
    return 0
end

local function filter(input, env)
    local xiami_exact = {}            -- 蝦米完整匹配
    local custom_exact = {}           -- 自定詞完整匹配
    local custom_completion = {}      -- 自定詞補全
    local kana_cands = {}
    local ext_cands = {}
    local english_cands = {}
    local exact_flushed = false       -- 完整匹配是否已輸出
    local show_extended = env.engine.context:get_option("extended_charset")

    for cand in input:iter() do
        local ctype = cand.type

        if ctype == "custom" then
            -- 自定詞完整匹配：暫存
            if exact_flushed then
                yield(cand)
            else
                custom_exact[#custom_exact + 1] = cand
            end
        elseif ctype == "custom_completion" then
            -- 自定詞補全：暫存到最後（在假名之前）
            if #custom_completion < MAX_BUFFER then
                custom_completion[#custom_completion + 1] = cand
            end
        elseif is_ascii_english(cand.text) then
            if #english_cands < MAX_BUFFER then
                english_cands[#english_cands + 1] = cand
            end
        else
            local cjk_type = get_cjk_type(cand.text)

            if cjk_type == 2 then
                -- 擴充字集
                if show_extended and #ext_cands < MAX_BUFFER then
                    ext_cands[#ext_cands + 1] = cand
                end
            elseif cjk_type == 1 then
                -- 假名
                if #kana_cands < MAX_BUFFER then
                    kana_cands[#kana_cands + 1] = cand
                end
            else
                -- 一般漢字（蝦米候選）
                local comment = cand.comment
                local is_completion = comment and (comment:sub(1, 1) == "~" or comment:find("▸", 1, true))

                if is_completion then
                    -- 蝦米補字：先輸出蝦米完整 + 自定詞完整，再輸出補字
                    if not exact_flushed then
                        exact_flushed = true
                        for i = 1, #xiami_exact do yield(xiami_exact[i]) end
                        xiami_exact = {}
                        for i = 1, #custom_exact do yield(custom_exact[i]) end
                        custom_exact = {}
                    end
                    yield(cand)
                else
                    -- 蝦米完整匹配：暫存
                    if exact_flushed then
                        yield(cand)
                    else
                        xiami_exact[#xiami_exact + 1] = cand
                    end
                end
            end
        end
    end

    -- 輸出剩餘的完整匹配（如果沒有蝦米補字的情況）
    for i = 1, #xiami_exact do yield(xiami_exact[i]) end
    for i = 1, #custom_exact do yield(custom_exact[i]) end
    -- 輸出自定詞補全
    for i = 1, #custom_completion do yield(custom_completion[i]) end
    -- 輸出假名
    for i = 1, #kana_cands do yield(kana_cands[i]) end
    -- 輸出擴充字集
    for i = 1, #ext_cands do yield(ext_cands[i]) end
    -- 輸出英文
    for i = 1, #english_cands do yield(english_cands[i]) end
end

return filter
