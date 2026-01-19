-- liu_data.lua
-- 共用資料中心
-- 負責載入並管理所有大型資料表，避免多個模組重複載入同一份資料
-- 支援動態釋放機制，配合 liu_gc_processor 使用

local M = {}

-- 私有數據存儲
local _w2c_data = nil
local _phonetic_data = {
    groups_trad = nil,
    groups_simp = nil,
    char_to_gids_trad = nil,
    char_to_gids_simp = nil
}

-- 清理回調函數（用於通知其他模組資料已被釋放）
local _cleanup_callbacks = {}

-- 輔助：讀取檔案內容
local function read_file_content(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local content = file:read("*all")
    file:close()
    return content
end

-- 輔助：獲取檔案路徑（優先用戶目錄，其次共享目錄）
local function get_file_path(filename)
    local user_dir = rime_api and rime_api.get_user_data_dir and rime_api.get_user_data_dir()
    local shared_dir = rime_api and rime_api.get_shared_data_dir and rime_api.get_shared_data_dir()
    
    if user_dir then
        local path = user_dir .. "/opencc/" .. filename
        local f = io.open(path, "r")
        if f then f:close(); return path end
    end
    
    if shared_dir then
        local path = shared_dir .. "/opencc/" .. filename
        local f = io.open(path, "r")
        if f then f:close(); return path end
    end
    
    return nil
end

-- ==========================================
-- 1. liu_w2c 資料管理
-- 用於：liu_w2c_sorter, liu_vrsf_hint, liu_phonetic_suffix
-- ==========================================

function M.get_w2c_data()
    if _w2c_data then return _w2c_data end

    local data = {}
    local path = get_file_path("liu_w2c.txt")
    
    if path then
        local content = read_file_content(path)
        if content then
             for line in content:gmatch("[^\r\n]+") do
                local char, code_str = line:match("^([^\t]+)\t~(.+)$")
                if char and code_str then
                    -- 為了記憶體優化，我們不再這裡做過多解析，只存儲字串
                    -- 需要的模組自己去解析
                    data[char] = code_str
                end
            end
        end
    end
    
    _w2c_data = data
    return _w2c_data
end

-- ==========================================
-- 2. 同音字資料管理
-- 用於：liu_phonetic_suffix
-- ==========================================

local function load_phonetic_groups(is_simplified)
    local groups = {}        -- 群組列表，每個元素是原始字串
    local char_to_gids = {}  -- 字 → "gid:pos,gid:pos,..."
    
    local filename = is_simplified and "liu_phonetic_simp.txt" or "liu_phonetic.txt"
    local path = get_file_path(filename)
    
    if path then
        local content = read_file_content(path)
        if content then
            local gid = 0
            for line in content:gmatch("[^\r\n]+") do
                local first_char, rest = line:match("^([^\t]+)\t(.+)$")
                if first_char and rest then
                    gid = gid + 1
                    -- 存儲完整的群組字串
                    groups[gid] = first_char .. " " .. rest
                    
                    -- 記錄每個字屬於哪些群組
                    local pos = 1
                    for char in (first_char .. " " .. rest):gmatch("[^ ]+") do
                        local entry = gid .. ":" .. pos
                        if char_to_gids[char] then
                            char_to_gids[char] = char_to_gids[char] .. "," .. entry
                        else
                            char_to_gids[char] = entry
                        end
                        pos = pos + 1
                    end
                end
            end
        end
    end
    
    return groups, char_to_gids
end


function M.get_phonetic_data(is_simplified)
    if is_simplified then
        if not _phonetic_data.groups_simp then
            _phonetic_data.groups_simp, _phonetic_data.char_to_gids_simp = load_phonetic_groups(true)
        end
        return _phonetic_data.groups_simp, _phonetic_data.char_to_gids_simp
    else
        if not _phonetic_data.groups_trad then
            _phonetic_data.groups_trad, _phonetic_data.char_to_gids_trad = load_phonetic_groups(false)
        end
        return _phonetic_data.groups_trad, _phonetic_data.char_to_gids_trad
    end
end

-- ==========================================
-- 3. 有效按鍵資料管理 (Memory Optimized)
-- 用於：liu_key_blocker
-- ==========================================

-- 快取有效按鍵表
local _valid_keys_cache = {}

function M.get_valid_keys_table(start_char)
    -- 如果 start_char 為空或 nil，表示查找 _root（空前綴對應的表）
    local key = start_char or "_root"
    if key == "" then key = "_root" end
    
    -- 若快取已有，直接返回
    if _valid_keys_cache[key] then
        return _valid_keys_cache[key]
    end
    
    -- 記憶體優化策略：
    -- 我們假設打字時，同一時間通常只會用到一個首字母的表。
    -- 當請求不同的首字母表時，清空舊的快取，只保留當前的。
    -- 這樣可以確保記憶體佔用維持在最小（只載入一個小檔案）。
    
    -- 清空舊快取 (Single Slot Cache)
    _valid_keys_cache = {}
    
    local data = {}
    local filename = "liu_valid_keys/" .. key .. ".txt"
    local path = get_file_path(filename)
    
    if path then
        local file = io.open(path, "r")
        if file then
            for line in file:lines() do
                -- 檔案格式：key<tab>valid_chars
                local k, v = line:match("^([^\t]+)\t([^\t]+)$")
                if k then
                    data[k] = v
                end
            end
            file:close()
        end
    end
    
    -- 存入快取
    _valid_keys_cache[key] = data
    return data
end


-- ==========================================
-- 記憶體管理
-- ==========================================

-- 註冊清理回調
function M.register_cleanup_callback(callback)
    table.insert(_cleanup_callbacks, callback)
end

-- 釋放所有大型資料
-- 由 liu_gc_processor 在記憶體壓力大或閒置時呼叫
function M.free_data()
    local freed = false
    
    if _w2c_data then 
        _w2c_data = nil 
        freed = true
    end
    
    if _phonetic_data.groups_trad or _phonetic_data.groups_simp then
        _phonetic_data = {
            groups_trad = nil,
            groups_simp = nil,
            char_to_gids_trad = nil,
            char_to_gids_simp = nil
        }
        freed = true
    end
    
    if next(_valid_keys_cache) then
        _valid_keys_cache = {}
        freed = true
    end
    
    -- 通知其他模組清理它們自己的快取（如果有的話）
    if freed then
        for _, cb in ipairs(_cleanup_callbacks) do
            pcall(cb)
        end
        -- 強制執行一次完整的垃圾回收
        collectgarbage("collect")
    end
end

return M
