-- liu_key_blocker.lua
-- 無效輸入遮蔽（防誤觸）
-- 根據字典前綴映射表，阻止無效的按鍵輸入
-- 支援動態讀取 openxiami_CustomWord.dict.yaml，自定詞優先權高於靜態屏蔽

local liu_data = require("liu_data")

-- 自定詞的前綴映射（動態載入）
local custom_prefix_map = nil

-- 從 openxiami_CustomWord.dict.yaml 載入自定詞並建立前綴映射
local function load_custom_prefix_map()
    if custom_prefix_map then return custom_prefix_map end
    custom_prefix_map = {}
    
    local user_dir = rime_api and rime_api.get_user_data_dir and rime_api.get_user_data_dir() or ""
    local shared_dir = rime_api and rime_api.get_shared_data_dir and rime_api.get_shared_data_dir() or ""
    
    local paths = {}
    if user_dir ~= "" then paths[#paths + 1] = user_dir .. "/openxiami_CustomWord.dict.yaml" end
    if shared_dir ~= "" then paths[#paths + 1] = shared_dir .. "/openxiami_CustomWord.dict.yaml" end
    
    for _, path in ipairs(paths) do
        local file = io.open(path, "r")
        if file then
            local in_data = false
            for line in file:lines() do
                if line == "..." then
                    in_data = true
                elseif in_data and #line > 0 and line:byte(1) ~= 35 then  -- 35 = '#'
                    local word, code = line:match("^([^\t]+)\t([^\t]+)")
                    if word and code then
                        code = code:lower()
                        -- 只處理純英文字母編碼
                        if code:match("^[a-z]+$") then
                            -- 將完整編碼加入映射（標記為有效）
                            custom_prefix_map[code] = true
                            -- 建立所有前綴的映射
                            for i = 1, #code - 1 do
                                local prefix = code:sub(1, i)
                                local next_char = code:sub(i + 1, i + 1)
                                if not custom_prefix_map[prefix] then
                                    custom_prefix_map[prefix] = {}
                                end
                                if type(custom_prefix_map[prefix]) == "table" then
                                    custom_prefix_map[prefix][next_char] = true
                                end
                            end
                            -- 空前綴：第一個字母
                            if not custom_prefix_map[""] then
                                custom_prefix_map[""] = {}
                            end
                            if type(custom_prefix_map[""]) == "table" then
                                custom_prefix_map[""][code:sub(1, 1)] = true
                            end
                        end
                    end
                end
            end
            file:close()
            break  -- 只讀取第一個找到的檔案
        end
    end
    
    return custom_prefix_map
end

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

-- 檢查輸入是否在自定詞映射中有效
local function is_valid_in_custom(input)
    local custom_map = load_custom_prefix_map()
    
    -- 完整編碼存在
    if custom_map[input] == true then
        return true
    end
    
    -- 檢查前綴 + 下一個字元
    local prefix = input:sub(1, -2)
    local last_char = input:sub(-1)
    
    if prefix == "" then
        local valid_chars = custom_map[""]
        if type(valid_chars) == "table" and valid_chars[last_char] then
            return true
        end
    else
        local valid_chars = custom_map[prefix]
        if type(valid_chars) == "table" and valid_chars[last_char] then
            return true
        end
    end
    
    return false
end

-- 檢查輸入是否有效（先檢查自定詞，再檢查靜態映射）
local function is_valid_prefix(input)
    if not input or #input == 0 then
        return true
    end
    
    local lower_input = input:lower()
    if not lower_input:match("^[a-z]+$") then
        return true
    end
    
    -- 超過 5 個字元不屏蔽（效能考量，中文編碼最長 5 碼）
    if #lower_input > 5 then
        return true
    end
    
    -- 優先檢查自定詞映射
    if is_valid_in_custom(lower_input) then
        return true
    end
    
    -- 檢查靜態映射 (Lazy Load)
    local start_char = lower_input:sub(1, 1)
    local valid_keys = liu_data.get_valid_keys_table(start_char)
    
    if valid_keys[lower_input] then
        return true
    end
    
    local prefix = lower_input:sub(1, -2)
    local last_char = lower_input:sub(-1)
    
    if prefix == "" then
        -- empty input is already handled by #input == 0 check or valid_keys["_root"]?
        -- lower_input > 0 len here. if len 1, prefix is empty.
        local valid_chars = valid_keys[""] -- In our file format, key "" maps to chars
        -- Actually, our file format:
        -- root.txt has "" -> "abcdef..."
        -- But get_valid_keys_table("_root") returns table { [""] = "..." }
        -- If start_char is 'a', we got table for 'a'.
        -- If input is "a", prefix is "", last is "a".
        -- Wait. If input is 'a', start_char is 'a'. Table is 'a.txt'. 
        -- Does 'a.txt' contain mapping for prefix ""? NO.
        -- 'a.txt' contains keys starting with 'a'.
        
        -- Special logic:
        -- If len == 1: check if char is valid start char. 
        -- valid_keys_data[""] = "abcdef..." in original.
        -- We stored that in _root.txt.
        
        -- To be efficient: any a-z is valid start.
        -- Just return true if length 1 and is a-z?
        return true
    end
    
    -- Check if prefix exists in the table
    local valid_chars = valid_keys[prefix]
    if valid_chars and valid_chars:find(last_char, 1, true) then
        return true
    end
    
    return false
end

local function processor(key, env)
    -- 只處理按下事件
    if key:release() then
        return 2  -- kNoop
    end
    
    local context = env.engine.context
    local input = context.input or ""
    
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
        return 2  -- kNoop（允許，讓 speller 處理）
    else
        -- 無效輸入：吃掉按鍵
        return 1  -- kAccepted
    end
end

return processor
