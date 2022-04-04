require("helper.math")
require("util")
require("helper.conversion")

balancer_functions = {}

---creates a new balancer object in the global stack
---This will NOT set the parts and the lanes!!
---@return Balancer the created balancer
function balancer_functions.new()
    ---@type Balancer
    local balancer = {}

    balancer.unit_number = get_next_balancer_unit_number()
    balancer.parts = {}
    balancer.nth_tick = 0
    balancer.buffer = {}
    balancer.input_lanes = {}
    balancer.output_lanes = {}

    global.balancer[balancer.unit_number] = balancer

    return balancer
end

---merge two balancer, the first balancer_index is the base, to merge things into.
---The second balancer (balancer_index2) will be deleted after it is merged.
---@param balancer_index uint
---@param balancer_index2 uint
function balancer_functions.merge(balancer_index, balancer_index2)
    local balancer = global.balancer[balancer_index]
    local balancer2 = global.balancer[balancer_index2]

    for k, part_index in pairs(balancer2.parts) do
        balancer.parts[k] = part_index

        -- change balancer link on part too
        local part = global.parts[part_index]
        part.balancer = balancer_index

        -- change balancer link on belts too
        for _, belt_index in pairs(part.input_belts) do
            local belt = global.belts[belt_index]
            belt.output_balancer[balancer_index2] = nil
            belt.output_balancer[balancer_index] = balancer_index
        end

        for _, belt_index in pairs(part.output_belts) do
            local belt = global.belts[belt_index]
            belt.input_balancer[balancer_index2] = nil
            belt.input_balancer[balancer_index] = balancer_index
        end
    end

    for k, v in pairs(balancer2.input_lanes) do
        balancer.input_lanes[k] = v
    end

    for k, v in pairs(balancer2.output_lanes) do
        balancer.output_lanes[k] = v
    end

    for _, item in pairs(balancer2.buffer) do
        table.insert(balancer.buffer, item)
    end

    -- remove merged balancer from the global stack
    global.balancer[balancer_index2] = nil

    -- unregister nth_tick
    unregister_on_tick(balancer_index2)
end

---This will find nearby balancer, creates/adds/merges balancer if needed.
---The part is automatically added to the balancer!
---@param part Part The part entity to work from
---@return uint The balancer index, that the part is part of :)
function balancer_functions.find_from_part(part)
    if part.balancer ~= nil then
        return part.balancer
    end

    local entity = part.entity

    local nearby_balancer_indices = part_functions.find_nearby_balancer(entity)
    local nearby_balancer_amount = table_size(nearby_balancer_indices)

    if nearby_balancer_amount == 0 then
        -- create new balancer
        local balancer = balancer_functions.new()
        balancer.parts[entity.unit_number] = entity.unit_number
        return balancer.unit_number
    elseif nearby_balancer_amount == 1 then
        -- add to existing balancer
        local balancer
        for _, index in pairs(nearby_balancer_indices) do
            balancer = global.balancer[index]
            balancer.parts[entity.unit_number] = entity.unit_number
        end
        return balancer.unit_number
    elseif nearby_balancer_amount >= 2 then
        -- add to existing balancer and merge them
        -- merge fond balancer
        local base_balancer_index
        for _, nearby_balancer_index in pairs(nearby_balancer_indices) do
            if not base_balancer_index then
                base_balancer_index = nearby_balancer_index

                -- add splitter to balancer
                local balancer = global.balancer[nearby_balancer_index]
                balancer.parts[entity.unit_number] = entity.unit_number
            else
                -- merge balancer and remove them from global table
                balancer_functions.merge(base_balancer_index, nearby_balancer_index)
            end
        end
        return base_balancer_index
    end
end

---recalculate_nth_tick
---@param balancer_index uint
function balancer_functions.recalculate_nth_tick(balancer_index)
    local balancer = global.balancer[balancer_index]

    if table_size(balancer.input_lanes) == 0 or table_size(balancer.output_lanes) == 0 or table_size(balancer.parts) == 0 then
        unregister_on_tick(balancer_index)
        balancer.nth_tick = 0
        return
    end

    -- recalculate nth_tick
    local tick_list = {}
    local run_on_tick_override = false

    for _, part in pairs(balancer.parts) do
        local stack_part = global.parts[part]
        for _, belt in pairs(stack_part.output_belts) do
            local stack_belt = global.belts[belt]
            local belt_speed = stack_belt.entity.prototype.belt_speed
            local ticks_per_tile = 0.25 / belt_speed
            local nth_tick = math.floor(ticks_per_tile)
            if nth_tick ~= ticks_per_tile then
                run_on_tick_override = true
                break
            end
            tick_list[nth_tick] = nth_tick
        end

        if run_on_tick_override then
            break
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
        unregister_on_tick(balancer_index)
        register_on_tick(smallest_gcd, balancer_index)
    end
end

function balancer_functions.run(balancer_index)
    local balancer = global.balancer[balancer_index]

    if table_size(balancer.input_lanes) > 0 and table_size(balancer.output_lanes) > 0 then
        -- get how many items are needed per lane
        local buffer_count = #balancer.buffer
        local output_lane_count = table_size(balancer.output_lanes)
        local gather_amount = (output_lane_count * 2) - buffer_count

        local next_lanes = balancer.input_lanes

        -- INPUT
        while gather_amount > 0 and table_size(next_lanes) > 0 do
            local current_lanes = next_lanes
            next_lanes = {}

            for k, lane_index in pairs(current_lanes) do
                local lane = global.lanes[lane_index]
                if #lane > 0 then
                    -- remove item from lane and add to buffer
                    local lua_item = lane[1]
                    local simple_item = convert_LuaItemStack_to_SimpleItemStack(lua_item)
                    lane.remove_item(lua_item)
                    table.insert(balancer.buffer, simple_item)
                    gather_amount = gather_amount - 1

                    next_lanes[k] = lane_index
                end
            end
        end

        -- create table with output lanes, with last_success at the beginning
        local output_lanes_sorted = {}
        local last_add_index = 0
        local found_last_success = false
        for _, lane in pairs(balancer.output_lanes) do
            if found_last_success then
                last_add_index = last_add_index + 1
                table.insert(output_lanes_sorted, last_add_index, lane)
            else
                table.insert(output_lanes_sorted, lane)
            end

            if lane == balancer.last_success then
                found_last_success = true
            end
        end

        -- put items onto the belt
        local second_iteration = {}
        for _, lane_index in pairs(output_lanes_sorted) do
            if #balancer.buffer > 0 then
                local lane = global.lanes[lane_index]
                if lane.can_insert_at_back() and lane.insert_at_back(balancer.buffer[1]) then
                    table.remove(balancer.buffer, 1)
                    balancer.last_success = lane_index
                end
            else
                break
            end
        end
    end
end

---check if this balancer still needs to be tracked, if not, remove it from global stack!
---@param balancer_index uint
---@param drop_to Item_drop_param
---@return boolean True if balancer is still tracked, false if balancer was removed
function balancer_functions.check_track(balancer_index, drop_to)
    local balancer = global.balancer[balancer_index]
    if table_size(balancer.parts) == 0 then
        -- balancer is not valid, remove it from global stack
        if table_size(balancer.output_lanes) > 0 or table_size(balancer.input_lanes) > 0 then
            print("Belt-balancer: Something is off with the removing of balancer lanes")
            print("balancer: ", balancer_index)
            print(serpent.block(global.balancer))
        end

        balancer_functions.empty_buffer(balancer, drop_to)

        global.balancer[balancer_index] = nil

        return false
    end

    return true
end

---empty_buffer
---@overload fun(balancer:Balancer, buffer:LuaInventory)
---@param balancer Balancer
---@param drop_to Item_drop_param
function balancer_functions.empty_buffer(balancer, drop_to)
    if drop_to.buffer and drop_to.buffer.valid then
        for _, item in pairs(balancer.buffer) do
            drop_to.buffer.insert(item)
        end
    else
        -- drop items on ground
        for _, item in pairs(balancer.buffer) do
            drop_to.surface.spill_item_stack(drop_to.position, item, false, drop_to.force)
        end
    end
end

---balancer_get_linked
---get all lined splitters into an array of LuaEntity
---@param balancer Balancer balancer to perform on
---@return LuaEntity[][]
function balancer_functions.get_linked(balancer)
    -- create matrix
    local matrix = {}
    for _, part_index in pairs(balancer.parts) do
        local part = global.parts[part_index]
        local pos = part.entity.position
        if not matrix[pos.x] then
            matrix[pos.x] = {}
        end
        matrix[pos.x][pos.y] = part.entity
    end

    local curr_num = 0
    local result = {}
    repeat
        curr_num = curr_num + 1
        balancer_functions.expand_first(matrix, curr_num, result)
    until (table_size(matrix) == 0)
    return result
end

---balancer_expand_first
---expand the first found not expanded Element in the matrix
---@param matrix LuaEntity[][] matrix to perform logic on
---@param num number
function balancer_functions.expand_first(matrix, num, result)
    for x_key, _ in pairs(matrix) do
        local breaker = false
        for y_key, _ in pairs(matrix[x_key]) do
            if matrix[x_key][y_key] then
                result[num] = {}
                balancer_functions.expand_matrix(matrix, { x = x_key, y = y_key }, num, result)
                breaker = true
                break
            end
        end

        if breaker then
            break
        end
    end
end

---balancer_expand_matrix
---expand given element in the matrix and then expand its neighbours
---only expand if this element is not nil
function balancer_functions.expand_matrix(matrix, pos, num, result)
    if matrix[pos.x] and matrix[pos.x][pos.y] then
        local part_entity = matrix[pos.x][pos.y]
        result[num][part_entity.unit_number] = part_entity
        matrix[pos.x][pos.y] = nil
        if table_size(matrix[pos.x]) == 0 then
            matrix[pos.x] = nil
        end

        balancer_functions.expand_matrix(matrix, { x = pos.x - 1, y = pos.y }, num, result)
        balancer_functions.expand_matrix(matrix, { x = pos.x + 1, y = pos.y }, num, result)
        balancer_functions.expand_matrix(matrix, { x = pos.x, y = pos.y - 1 }, num, result)
        balancer_functions.expand_matrix(matrix, { x = pos.x, y = pos.y + 1 }, num, result)
    end
end

---create a new balancer with already created parts
---@param part_list LuaEntity[]
---@return Balancer
function balancer_functions.new_from_part_list(part_list)
    local balancer = balancer_functions.new()

    for _, part_entity in pairs(part_list) do
        local part = global.parts[part_entity.unit_number]

        -- add part to balancer
        balancer.parts[part_entity.unit_number] = part_entity.unit_number

        -- add balancer to part
        part.balancer = balancer.unit_number

        for _, belt_index in pairs(part.input_belts) do
            local belt = global.belts[belt_index]

            -- add balancer to belt
            belt.output_balancer[balancer.unit_number] = balancer.unit_number
        end

        for _, belt_index in pairs(part.output_belts) do
            local belt = global.belts[belt_index]

            -- add balancer to belt
            belt.input_balancer[balancer.unit_number] = balancer.unit_number
        end

        -- add lanes to balancer
        for _, lane in pairs(part.input_lanes) do
            balancer.input_lanes[lane] = lane
        end
        for _, lane in pairs(part.output_lanes) do
            balancer.output_lanes[lane] = lane
        end
    end

    balancer_functions.recalculate_nth_tick(balancer.unit_number)

    return balancer
end

---check if this balancer still is one piece, if not, create multiple balancer if needed.
---@param balancer_index uint
---@param drop_to Item_drop_param
function balancer_functions.check_connected(balancer_index, drop_to)
    local balancer = global.balancer[balancer_index]

    local linked = balancer_functions.get_linked(balancer)
    if table_size(linked) > 1 then
        -- unregister balancer, before splitting it
        unregister_on_tick(balancer_index)

        -- create multiple new balancer
        for _, parts in pairs(linked) do
            balancer_functions.new_from_part_list(parts)
        end

        -- remove old balancer from belts
        for _, part_index in pairs(balancer.parts) do
            local part = global.parts[part_index]
            for _, belt_index in pairs(part.input_belts) do
                local belt = global.belts[belt_index]
                belt.input_balancer[balancer_index] = nil
                belt.output_balancer[balancer_index] = nil
            end
            for _, belt_index in pairs(part.output_belts) do
                local belt = global.belts[belt_index]
                belt.input_balancer[balancer_index] = nil
                belt.output_balancer[balancer_index] = nil
            end
        end

        -- clear the old balancer buffer
        balancer_functions.empty_buffer(balancer, drop_to)

        -- finally, remove old balancer form global stack
        global.balancer[balancer_index] = nil
    end
end

return balancer_functions
