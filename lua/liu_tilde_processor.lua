-- liu_tilde_processor.lua
-- 處理波浪號直出：單獨輸入 ~ 時直接輸出，不進入候選框（造詞模式除外）

local function processor(key, env)
    local engine = env.engine
    local context = engine.context
    local input = context.input
    
    -- 只處理按下事件，不處理釋放事件
    if key:release() then
        return 2  -- kNoop
    end
    
    local keycode = key.keycode
    
    -- 處理波浪號 ~ (ASCII 126)
    if keycode == 126 or keycode == 0x7E then
        -- 如果在造詞模式（; 開頭），讓 Rime 處理
        if input:match("^;") then
            return 2  -- kNoop
        end
        
        -- 如果輸入為空，直接輸出 ~
        if input == "" then
            engine:commit_text("~")
            return 1  -- kAccepted
        end
        
        -- 如果有候選字，先確認當前選擇
        if context:has_menu() then
            context:confirm_current_selection()
        end
        
        -- 上屏當前內容
        context:commit()
        
        -- 輸出 ~
        engine:commit_text("~")
        return 1  -- kAccepted
    end
    
    return 2  -- kNoop
end

return processor
