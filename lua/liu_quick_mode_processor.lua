-- liu_quick_mode_processor.lua
-- 處理快捷鍵切換模式及強制快打邏輯
-- ,,sp = 快打提示模式
-- ,,sf = 強制快打模式
-- ,,wc = 萬用查字模式 (wildcard)

-- Opencc 實例（延遲載入）
local opencc_liu_w2c = nil

-- 獲取 Opencc 實例
local function get_opencc()
    if not opencc_liu_w2c then
        opencc_liu_w2c = Opencc("liu_w2c.json")
    end
    return opencc_liu_w2c
end

-- 從 Opencc 返回的編碼字串中找最短的簡碼
-- 輸入格式："⟨e⟩ ⟨f^v⟩ ⟨abc⟩"
-- 返回：所有最短簡碼組成的字串，或 nil
local function find_shortest_codes(codes_str, max_len)
    if not codes_str or codes_str == "" then
        return nil
    end
    
    local all_codes = {}
    local min_len = max_len
    
    -- 解析 ⟨code⟩ 格式的編碼
    codes_str = codes_str:gsub("\\⟩", "\x01")
    for code in codes_str:gmatch("⟨([^⟩]+)⟩") do
        code = code:gsub("\x01", "⟩")
        
        -- 只考慮「第一候選」的編碼（沒有 ^ 的）
        if not code:find("^", 1, true) then
            local len = #code
            if len < max_len then
                all_codes[#all_codes + 1] = {code = code, len = len}
                if len < min_len then
                    min_len = len
                end
            end
        end
    end
    
    -- 收集所有最短長度的編碼
    local shortest_codes = {}
    for _, item in ipairs(all_codes) do
        if item.len == min_len then
            shortest_codes[#shortest_codes + 1] = item.code
        end
    end
    
    if #shortest_codes == 0 then
        return nil
    end
    
    return table.concat(shortest_codes, "⟩⟨")
end

-- 檢查是否應該阻止上屏
local function should_block_commit(context)
    local input_text = context.input
    local input_length = #input_text
    
    -- 輸入 < 4 碼，允許上屏
    if input_length < 4 then
        return false
    end
    
    -- 特殊模式，允許上屏
    local first_char = input_text:sub(1, 1)
    if first_char == ";" or first_char == "`" or first_char == "'" or first_char == "," then
        return false
    end
    
    -- 檢查第一個候選是否為單字且有簡碼
    local composition = context.composition
    if composition and not composition:empty() then
        local seg = composition:back()
        if seg and seg.menu and seg.menu:candidate_count() > 0 then
            local cand = seg:get_selected_candidate()
            if cand and utf8.len(cand.text) == 1 then
                -- 獲取 Opencc
                local opencc = get_opencc()
                if not opencc then
                    return false
                end
                
                local char = cand.text
                local is_simplified = context:get_option("simplification")
                
                -- 簡體模式：從 comment 提取繁體字
                local lookup_char = char
                if is_simplified then
                    local comment = cand.comment
                    if comment then
                        local trad = comment:match("〔(.)〕")
                        if trad then
                            lookup_char = trad
                        end
                    end
                end
                
                -- 用 Opencc 查詢編碼
                local codes_str = opencc:convert(lookup_char)
                if codes_str == lookup_char then
                    codes_str = nil
                end
                
                local shortest_codes = find_shortest_codes(codes_str, input_length)
                if shortest_codes then
                    -- 檢查當前輸入是否為簡碼
                    for code in shortest_codes:gmatch("[^⟩⟨]+") do
                        if input_text:upper() == code:upper() then
                            return false  -- 使用了簡碼，允許上屏
                        end
                    end
                    return true  -- 有簡碼但沒使用，阻止上屏
                end
            end
        end
    end
    
    return false  -- 其他情況允許上屏
end

local function processor(key, env)
    local context = env.engine.context
    local input = context.input
    local key_repr = key:repr()
    
    -- ,,sp + 空格 = 切換快打提示模式
    if input == ",,sp" and key_repr == "space" then
        local current_quick = context:get_option("quick_mode")
        local current_force = context:get_option("force_quick_mode")
        
        if current_quick then
            -- 快打提示已開啟 → 關閉快打提示
            context:set_option("quick_mode", false)
        else
            -- 快打提示未開啟 → 開啟快打提示
            -- 先關閉強制快打（互斥），再開啟快打提示（確保顯示正確）
            if current_force then
                context:set_option("force_quick_mode", false)
            end
            context:set_option("quick_mode", true)
        end
        context:clear()
        return 1
    end
    
    -- ,,sf + 空格 = 切換強制快打模式
    if input == ",,sf" and key_repr == "space" then
        local current_quick = context:get_option("quick_mode")
        local current_force = context:get_option("force_quick_mode")
        
        if current_force then
            -- 強制快打已開啟 → 關閉強制快打
            context:set_option("force_quick_mode", false)
        else
            -- 強制快打未開啟 → 開啟強制快打
            -- 先關閉快打提示（互斥），再開啟強制快打（確保顯示正確）
            if current_quick then
                context:set_option("quick_mode", false)
            end
            context:set_option("force_quick_mode", true)
        end
        context:clear()
        return 1
    end
    
    -- ,,wc + 空格 = 切換萬用查字模式 (wildcard)
    -- if input == ",,wc" and key_repr == "space" then
    --     context:set_option("wildcard_mode", not context:get_option("wildcard_mode"))
    --     context:clear()
    --     return 1
    -- end
    
    -- 強制快打模式下攔截空格鍵
    if context:get_option("force_quick_mode") and key_repr == "space" then
        if should_block_commit(context) then
            return 1  -- 攔截空格鍵，阻止上屏
        end
    end
    
    return 2
end

return processor
