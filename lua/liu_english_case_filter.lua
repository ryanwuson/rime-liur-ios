-- liu_english_case_filter.lua
-- 英文大小寫轉換：
-- word] → Word（首字母大寫）
-- word]] → WORD（全大寫）

local function capitalize(str)
    -- 首字母大寫
    if #str == 0 then return str end
    return str:sub(1, 1):upper() .. str:sub(2):lower()
end

local function filter(input, env)
    local context = env.engine.context
    local raw_input = context.input
    local caret_pos = context.caret_pos

    -- 檢查是否以 ]] 或 ] 結尾
    local suffix = nil
    local base_input = nil

    if raw_input:sub(-2) == "]]" then
        suffix = "]]"
        base_input = raw_input:sub(1, -3)
    elseif raw_input:sub(-1) == "]" then
        suffix = "]"
        base_input = raw_input:sub(1, -2)
    end

    -- 先輸出原始候選
    for cand in input:iter() do
        yield(cand)
    end

    -- 如果有尾綴，生成大小寫轉換候選
    if suffix and base_input and #base_input > 0 then
        -- 只處理純英文輸入
        if base_input:match("^[a-zA-Z%-%.]+$") then
            local start = context:get_preedit().sel_start
            local _end = caret_pos

            if suffix == "]]" then
                -- 全大寫
                local upper_text = base_input:upper()
                local cand = Candidate("en_case", start, _end, upper_text, "〔全大寫〕")
                yield(cand)
            elseif suffix == "]" then
                -- 首字母大寫
                local cap_text = capitalize(base_input)
                local cand = Candidate("en_case", start, _end, cap_text, "〔首字大寫〕")
                yield(cand)
            end
        end
    end
end

return filter
