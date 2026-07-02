local function processor(key, env)
    if key:repr() == "Control+equal" then
        local schema_id = env.engine.schema.schema_id
        if schema_id == "easy_en" then
            env.engine.context:push_input("cal=") 
        else
            env.engine.context:push_input(",,=") 
        end
        return 1 -- kAccepted
    end
    return 2 -- kNoop
end

return { init = function() end, func = processor }
