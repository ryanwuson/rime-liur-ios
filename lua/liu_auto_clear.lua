-- liu_auto_clear.lua
-- 無候選時自動回退：檢測輸入是否有效，無效則回退一位
-- 用於手機輸入減少誤觸

local liu_data = require("liu_data")

-- 檢查是否為特殊模式
local function is_special_mode(input, context)
    if not input or #input == 0 then
        return false
    end
    
    local first_char = input:sub(1, 1)
    local first_two = input:sub(1, 2)
    
    if first_char == "`" or 
       first_char == ";" or 
       first_two == "';" or
       first_two == ",," then
        return true
    end
    
    if context:get_option("liu_w2c") then
        return true
    end
    
    if input:find("%?") then
        return true
    end
    
    return false
end

-- 檢查輸入是否有效
local function is_valid_prefix(input)
    if not input or #input == 0 then
        return true
    end
    
    local lower_input = input:lower()
    if not lower_input:match("^[a-z]+$") then
        return true
    end
    
    if #lower_input > 5 then
        return true
    end
    
    -- Lazy Load logic using liu_data
    local start_char = lower_input:sub(1, 1)
    local valid_keys = liu_data.get_valid_keys_table(start_char)
    
    if valid_keys[lower_input] then
        return true
    end
    
    local prefix = lower_input:sub(1, -2)
    local last_char = lower_input:sub(-1)
    
    if prefix == "" then
        -- Empty prefix logic (same as liu_key_blocker)
        return true
    end
    
    local valid_chars = valid_keys[prefix]
    if valid_chars and valid_chars:find(last_char, 1, true) then
        return true
    end
    
    return false
end

-- processor 函數
local function processor(key, env)
    local context = env.engine.context
    local input = context.input or ""
    
    -- 只處理按下事件
    if key:release() then
        return 2  -- kNoop
    end
    
    -- 特殊模式不處理
    if is_special_mode(input, context) then
        return 2  -- kNoop
    end
    
    -- 取得按鍵字元
    local kc = key.keycode
    local key_char = nil
    
    -- 小寫字母 a-z (97-122)
    if kc >= 97 and kc <= 122 then
        key_char = string.char(kc)
    -- 大寫字母 A-Z (65-90) 轉小寫
    elseif kc >= 65 and kc <= 90 then
        key_char = string.char(kc + 32)
    end
    
    -- 非字母鍵：不處理
    if not key_char then
        return 2  -- kNoop
    end
    
    -- 有修飾鍵：不處理
    if key:ctrl() or key:alt() then
        return 2  -- kNoop
    end
    
    -- VRSF 選字輔碼：有候選時允許
    local vrsf_keys = { v = true, r = true, s = true, f = true }
    if vrsf_keys[key_char] and context:has_menu() then
        return 2  -- kNoop
    end
    
    -- 模擬新輸入
    local new_input = input .. key_char
    
    -- 檢查新輸入是否有效
    if is_valid_prefix(new_input) then
        -- 有效：直接設定 input，然後刷新
        context.input = new_input
        context:refresh_non_confirmed_composition()
        return 1  -- kAccepted
    else
        -- 無效：不改變 input，直接返回 kAccepted（吃掉按鍵）
        return 1  -- kAccepted
    end
end

return processor
