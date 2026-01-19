-- liu_gc_processor.lua
-- 記憶體管理與垃圾回收處理器
-- 專為解決 iOS 記憶體限制問題而設計

local liu_data = require("liu_data")

local check_interval = 20            -- 每多少次擊鍵檢查一次
local key_count = 0
local memory_threshold = 15 * 1024   -- 15MB 閾值 (iOS 限制嚴格)
local aggressive_gc_threshold = 30 * 1024 -- 30MB 強制 GC

local function cleanup_memory(force)
    -- 1. 獲取目前記憶體用量 (KB)
    local mem_usage = collectgarbage("count")
    
    -- 2. 如果超過閾值或強制清理
    if force or mem_usage > memory_threshold then
        -- 釋放大型資料 (liu_w2c, liu_phonetic)
        -- 注意：這不會影響正在輸入的體驗，因為下次需要時會自動重載
        -- 但在連續打字時頻繁重載會影響效能，所以通常在 commit 後執行
        liu_data.free_data()
        
        -- 強制執行完整的垃圾回收
        collectgarbage("collect")
        
        -- 記錄日誌 (可選，除錯用)
        -- log.info("GC Triggered: " .. math.floor(mem_usage) .. "KB -> " .. math.floor(collectgarbage("count")) .. "KB")
    else
        -- 輕量級回收
        collectgarbage("step")
    end
end

local function processor(key, env)
    local context = env.engine.context
    
    -- 1. 監聽 Commit 事件 (上屏)
    -- 當文字上屏後，通常是清理記憶體的最佳時機
    local commit_notifier = context.commit_notifier
    if not env.commit_connection then
        env.commit_connection = commit_notifier:connect(function(ctx)
            -- 上屏後，延遲一小段時間或立即清理
            -- 這裡選擇立即清理，因為已經完成輸入
            cleanup_memory(true) 
        end)
    end
    
    -- 2. 週期性檢查 (防止輸入長句時記憶體暴增)
    key_count = key_count + 1
    if key_count >= check_interval then
        key_count = 0
        local mem_usage = collectgarbage("count")
        
        if mem_usage > aggressive_gc_threshold then
            -- 危險水位：強制清理
            cleanup_memory(true)
        elseif mem_usage > memory_threshold then
            -- 警戒水位：嘗試釋放暫存資料
            liu_data.free_data()
            collectgarbage("step", 100)
        else
            -- 正常水位：輕量回收
            collectgarbage("step")
        end
    end

    return 2 -- kNoop
end

return processor