---register_on_tick
---@param tick number
---@param balancer_id the balancer that runs on this tick
function register_on_tick(tick, balancer_id)
    if global.events[tick] then
        table.insert(global.events[tick], balancer_id)
    else
        global.events[tick] = {}
        table.insert(global.events[tick], balancer_id)

        script.on_nth_tick(tick, on_tick)
    end
end

---unregister_on_tick
---@param balancer_id number
---@return number the tick, that got removed
function unregister_on_tick(balancer_id)
    for tick, arr in pairs(global.events) do
        if remove_from_table(arr, balancer_id) then
            if #global.events[tick] == 0 then
                -- unregister this tick
                script.on_nth_tick(tick, nil)
            end
        end
    end
end

function on_tick(e)
    for _, balancer_id in pairs(global.events[e.nth_tick]) do
        balancer_on_tick(balancer_id)
    end
end
