--require("objects.balancer")

function math.gcd(a, b)
    -- great common divisor (euclidean algorithm)
    while b ~= 0 do
        a, b = b, a % b
    end
    return a
end

---balancer_recalculate_nth_tick
---Recalculate the tick, when this balancer has to run.
---It has to be the gcd, cause else, some belts are not compressed
---@param balancer_id number balancer to perform on
function balancer_recalculate_nth_tick(balancer_id)
    local balancer = global.new_balancers[balancer_id]

    if table_size(balancer.input_belts) == 0 or table_size(balancer.output_belts) == 0 then
        unregister_on_tick(balancer_id)
        balancer.nth_tick = -1
        return
    end

    -- recalculate nth_tick
    local tick_list = {}
    local run_on_tick_override = false

    for _, belt in pairs(balancer.input_belts) do
        if belt.valid then
            local belt_speed = belt.prototype.belt_speed
            local ticks_per_tile = 0.25 / belt_speed
            local nth_tick = math.floor(ticks_per_tile)
            if nth_tick ~= ticks_per_tile then
                run_on_tick_override = true
                break
            end
            tick_list[nth_tick] = nth_tick
        end
    end

    if not run_on_tick_override then
        for _, belt in pairs(balancer.output_belts) do
            if belt.valid then
                local belt_speed = belt.prototype.belt_speed
                local ticks_per_tile = 0.25 / belt_speed
                local nth_tick = math.floor(ticks_per_tile)
                if nth_tick ~= ticks_per_tile then
                    run_on_tick_override = true
                    break
                end
                tick_list[nth_tick] = nth_tick
            end
        end
    end

    local smallest_gcd = -1
    if not run_on_tick_override then
        for _, tick in pairs(tick_list) do
            if smallest_gcd == -1 then
                smallest_gcd = tick
            elseif smallest_gcd == 1 then
                break
            elseif smallest_gcd == tick then
                -- do nothing
            else
                smallest_gcd = math.gcd(smallest_gcd, tick)
            end
        end
    end

    if run_on_tick_override then
        smallest_gcd = 1
    end
    if smallest_gcd ~= -1 and balancer.nth_tick ~= smallest_gcd then
        balancer.nth_tick = smallest_gcd
        unregister_on_tick(balancer_id)
        register_on_tick(smallest_gcd, balancer_id)
    end
end

-- balancer_recalculate_nth_tick on every existing balancer
for k, _ in pairs(global.new_balancers) do
    balancer_recalculate_nth_tick(k)
end
