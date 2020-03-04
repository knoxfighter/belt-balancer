require("helper.table")

---register_on_tick
---@param tick number
---@param balancer_index uint the balancer that runs on this tick
function register_on_tick(tick, balancer_index)
    if global.events[tick] then
        table.insert(global.events[tick], balancer_index)
    else
        global.events[tick] = {}
        table.insert(global.events[tick], balancer_index)

        script.on_nth_tick(tick, on_tick)
    end
end

---unregister_on_tick
---@param balancer_index uint
function unregister_on_tick(balancer_index)
    for tick, arr in pairs(global.events) do
        if remove_from_table(arr, balancer_index) then
            if #global.events[tick] == 0 then
                -- unregister this tick
                script.on_nth_tick(tick, nil)
                global.events[tick] = nil
            end
        end
    end
end

function on_tick(e)
    for _, balancer_id in pairs(global.events[e.nth_tick]) do
        balancer_functions.run(balancer_id)
    end
end

function reregister_on_tick()
    -- reregister balancer
    for tick, _ in pairs(global.events) do
        script.on_nth_tick(tick, on_tick)
    end
end
