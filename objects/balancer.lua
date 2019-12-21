require("helper/table")
require("helper/conversion")
require("helper/math")

---find_nearby_balancer
---find neaby balancers, by searching on the map for nearby entities
---and then creating a unique list with them.
---Only index returned, to always use the original data and operate on them
---
---@param entity LuaEntity the newly placed splitter
---@return number[] unique list of found balancers (only indices)
function find_nearby_balancer(entity)
    local found_splitters = entity.surface.find_entities_filtered {
        position = entity.position,
        name = "belt-balancer",
        radius = 1,
    }
    if #found_splitters == 1 then
        return {}
    end
    local found_balancers = {}
    for key, balancer in pairs(global.new_balancers) do
        for _, found_splitter in pairs(found_splitters) do
            if found_splitter.unit_number ~= entity.unit_number then
                if balancer_has_splitter(key, found_splitter) then
                    found_balancers[balancer.index] = balancer.index
                    break
                end
            end
        end
    end

    return found_balancers
end

---find_input_output_belts
---find input and output belts for this specific splitter
---@param splitter LuaEntity the splitter to search from
---@return table[],table[] -- found input and output belts. Object is no direct array: array[number]{ LuaEntity belt, string belt_type, ?number[] lanes }
function find_input_output_belts(splitter)
    local splitter_pos = splitter.position
    -- input_belts[belt_index] = { belt, belt_type, lanes }
    local input_belts = {}
    -- output_belts[belt_index] = { belt, belt_type, lanes }
    local output_belts = {}

    local found_belts = splitter.surface.find_entities_filtered {
        position = splitter_pos,
        type = "transport-belt",
        radius = 1
    }
    for _, belt in pairs(found_belts) do
        local into_pos, from_pos = get_input_output_pos(belt)
        if into_pos.x == splitter_pos.x and into_pos.y == splitter_pos.y then
            input_belts[belt.unit_number] = { belt = belt, belt_type = "belt" }
        elseif from_pos.x == splitter_pos.x and from_pos.y == splitter_pos.y then
            output_belts[belt.unit_number] = { belt = belt, belt_type = "belt" }
        end
    end

    local found_underground_belts = splitter.surface.find_entities_filtered {
        position = splitter_pos,
        type = "underground-belt",
        radius = 1
    }
    for _, underground_belt in pairs(found_underground_belts) do
        local into_pos, from_pos = get_input_output_pos(underground_belt)
        if underground_belt.belt_to_ground_type == "output" and into_pos.x == splitter_pos.x and into_pos.y == splitter_pos.y then
            input_belts[underground_belt.unit_number] = { belt = underground_belt, belt_type = "underground" }
        elseif underground_belt.belt_to_ground_type == "input" and from_pos.x == splitter_pos.x and from_pos.y == splitter_pos.y then
            output_belts[underground_belt.unit_number] = { belt = underground_belt, belt_type = "underground" }
        end
    end

    local found_splitter_belts = splitter.surface.find_entities_filtered {
        position = splitter_pos,
        type = "splitter",
        radius = 1.5
    }
    for _, splitter_belt in pairs(found_splitter_belts) do
        local into_pos, from_pos = get_input_output_pos_splitter(splitter_belt)
        for _, into in pairs(into_pos) do
            if into.position.x == splitter_pos.x and into.position.y == splitter_pos.y then
                input_belts[splitter_belt.unit_number] = { belt = splitter_belt, belt_type = "splitter", lanes = into.lanes }
            end
        end
        for _, from in pairs(from_pos) do
            if from.position.x == splitter_pos.x and from.position.y == splitter_pos.y then
                output_belts[splitter_belt.unit_number] = { belt = splitter_belt, belt_type = "splitter", lanes = from.lanes }
            end
        end
    end

    return input_belts, output_belts
end

---find_belonging_balancer
---find which balancer holds this splitter
---@param splitter LuaEntity splitter to find
---@return number Index of the Balancer with the splitter within
function find_belonging_balancer(splitter)
    for index, _ in pairs(global.new_balancers) do
        if balancer_has_splitter(index, splitter) then
            return index
        end
    end
end

---get_input_output_pos
---get the positions where the belt will transport items from and to
---@param belt LuaEntity the belt to calculate on
---@return Position,Position return the positions (into, from)
---@param direction defines.direction override the direction of the belt. if nil will use belt.direction
function get_input_output_pos(belt, direction)
    local belt_pos = belt.position
    local into_pos, from_pos
    direction = direction or belt.direction

    if direction == defines.direction.north then
        into_pos = { x = belt_pos.x, y = belt_pos.y - 1 }
        from_pos = { x = belt_pos.x, y = belt_pos.y + 1 }
    elseif direction == defines.direction.south then
        into_pos = { x = belt_pos.x, y = belt_pos.y + 1 }
        from_pos = { x = belt_pos.x, y = belt_pos.y - 1 }
    elseif direction == defines.direction.west then
        into_pos = { x = belt_pos.x - 1, y = belt_pos.y }
        from_pos = { x = belt_pos.x + 1, y = belt_pos.y }
    elseif direction == defines.direction.east then
        into_pos = { x = belt_pos.x + 1, y = belt_pos.y }
        from_pos = { x = belt_pos.x - 1, y = belt_pos.y }
    end

    return into_pos, from_pos
end

---get_input_output_pos_splitter
---get the positions where the splitter will transport items from and to
---@param splitter LuaEntity the splitter to calculate on
---@param direction defines.direction override the direction of the belt. if nil will use belt.direction
---@return table[],table[] returns array (from,into) of positions and belt-lanes. -- array[] = { Position, array[] = number }.
function get_input_output_pos_splitter(splitter, direction)
    local splitter_pos = splitter.position
    direction = direction or splitter.direction
    local into_pos = {}
    local from_pos = {}
    local output_left_lanes = { 5, 6 }
    local output_right_lanes = { 7, 8 }
    local input_left_lanes = { 1, 2 }
    local input_right_lanes = { 3, 4 }

    if direction == defines.direction.north then
        table.insert(into_pos, { position = { x = splitter_pos.x - 0.5, y = splitter_pos.y - 1 }, lanes = output_left_lanes })
        table.insert(into_pos, { position = { x = splitter_pos.x + 0.5, y = splitter_pos.y - 1 }, lanes = output_right_lanes })
        table.insert(from_pos, { position = { x = splitter_pos.x - 0.5, y = splitter_pos.y + 1 }, lanes = input_left_lanes })
        table.insert(from_pos, { position = { x = splitter_pos.x + 0.5, y = splitter_pos.y + 1 }, lanes = input_right_lanes })
    elseif direction == defines.direction.south then
        table.insert(into_pos, { position = { x = splitter_pos.x - 0.5, y = splitter_pos.y + 1 }, lanes = output_right_lanes })
        table.insert(into_pos, { position = { x = splitter_pos.x + 0.5, y = splitter_pos.y + 1 }, lanes = output_left_lanes })
        table.insert(from_pos, { position = { x = splitter_pos.x - 0.5, y = splitter_pos.y - 1 }, lanes = input_right_lanes })
        table.insert(from_pos, { position = { x = splitter_pos.x + 0.5, y = splitter_pos.y - 1 }, lanes = input_left_lanes })
    elseif direction == defines.direction.west then
        table.insert(into_pos, { position = { x = splitter_pos.x - 1, y = splitter_pos.y - 0.5 }, lanes = output_right_lanes })
        table.insert(into_pos, { position = { x = splitter_pos.x - 1, y = splitter_pos.y + 0.5 }, lanes = output_left_lanes })
        table.insert(from_pos, { position = { x = splitter_pos.x + 1, y = splitter_pos.y - 0.5 }, lanes = input_right_lanes })
        table.insert(from_pos, { position = { x = splitter_pos.x + 1, y = splitter_pos.y + 0.5 }, lanes = input_left_lanes })
    elseif direction == defines.direction.east then
        table.insert(into_pos, { position = { x = splitter_pos.x + 1, y = splitter_pos.y - 0.5 }, lanes = output_left_lanes })
        table.insert(into_pos, { position = { x = splitter_pos.x + 1, y = splitter_pos.y + 0.5 }, lanes = output_right_lanes })
        table.insert(from_pos, { position = { x = splitter_pos.x - 1, y = splitter_pos.y - 0.5 }, lanes = input_left_lanes })
        table.insert(from_pos, { position = { x = splitter_pos.x - 1, y = splitter_pos.y + 0.5 }, lanes = input_right_lanes })
    end

    return into_pos, from_pos
end

---get_balancer_index_from_pos
---@param surface LuaSurface Surface where it is
---@param position Position Position to look for balancer
---@return number Balancer index
function get_balancer_index_from_pos(surface, position)
    local splitters = surface.find_entities_filtered {
        position = position,
        name = "belt-balancer"
    }
    for _, splitter in pairs(splitters) do
        return find_belonging_balancer(splitter)
    end
end

---get_input_output_balancer_index
---get the index of the input and output balancers, this belt belongs to.
---@param belt LuaEntity the belt to search from
---@param direction defines.direction override the direction of the belt.
---@return number,number into_balancer, from_balancer
function get_input_output_balancer_index(belt, direction)
    local into_pos, from_pos = get_input_output_pos(belt, direction)
    local into_balancer, from_balancer

    local into_splitter = belt.surface.find_entities_filtered {
        position = into_pos,
        name = "belt-balancer",
    }
    for _, splitter in pairs(into_splitter) do
        into_balancer = find_belonging_balancer(splitter)
    end

    local from_splitter = belt.surface.find_entities_filtered {
        position = from_pos,
        name = "belt-balancer"
    }
    for _, splitter in pairs(from_splitter) do
        from_balancer = find_belonging_balancer(splitter, direction)
    end

    return into_balancer, from_balancer
end

---new_balancer
---constructor of Balancer_Class
---@param splitter LuaEntity
function new_balancer(splitter)
    local new_balancer = {}
    new_balancer.index = global.belt_balancer_max_id
    global.new_balancers[new_balancer.index] = new_balancer
    global.belt_balancer_max_id = global.belt_balancer_max_id + 1

    -- list of all splitters, that form this balancer
    new_balancer.splitter = {}

    -- list of all input belts
    new_balancer.input_belts = {}

    -- list of all output belts
    new_balancer.output_belts = {}

    -- list of all input lanes
    new_balancer.input_lanes = {}

    -- list of all output lanes
    new_balancer.output_lanes = {}

    -- define current position of lanes
    new_balancer.current_output_lane = 1
    new_balancer.current_input_lane = 1

    ---@type SimpleItemStack[]
    new_balancer.buffer = {}

    new_balancer.nth_tick = 999

    if type(splitter) == "table" and splitter.name == "belt-balancer" then
        balancer_add_splitter(new_balancer.index, splitter)
    elseif type(splitter) == "table" then
        for _, splitter_single in pairs(splitter) do
            balancer_add_splitter(new_balancer.index, splitter_single)
        end
    end
end

---balancer_add_splitter
---@param balancer_id number balancer to perform on
---@param splitter LuaEntity splitter to add
function balancer_add_splitter(balancer_id, splitter)
    global.new_balancers[balancer_id].splitter[splitter.unit_number] = splitter

    local input_belts, output_belts = find_input_output_belts(splitter)
    for _, input_belt in pairs(input_belts) do
        balancer_add_belt(balancer_id, input_belt.belt, true, input_belt.belt_type, input_belt.lanes)
    end
    for _, output_belt in pairs(output_belts) do
        balancer_add_belt(balancer_id, output_belt.belt, false, output_belt.belt_type, output_belt.lanes)
    end
end

---balancer_remove_splitter
---@param balancer_id number balancer to perform on
---@param splitter LuaEntity splitter to remove
function balancer_remove_splitter(balancer_id, splitter)
    local balancer = global.new_balancers[balancer_id]
    balancer.splitter[splitter.unit_number] = nil

    local input_belts, output_belts = find_input_output_belts(splitter)
    for _, input_belt in pairs(input_belts) do
        balancer_remove_belt(balancer_id, input_belt.belt, true)
    end
    for _, output_belt in pairs(output_belts) do
        balancer_remove_belt(balancer_id, output_belt.belt, false)
    end
end

---balancer_add_belt
---@param balancer_id number balancer to perform on
---@param belt LuaEntity the belt to add
---@param input boolean true if input, false if output
---@param belt_type string "belt", "underground" or "splitter"
---@param lane_ids number[] array of numbers, that override, the automatic transport_line indices
function balancer_add_belt(balancer_id, belt, input, belt_type, lane_ids)
    belt_type = belt_type or "belt"
    lane_ids = lane_ids or nil
    local balancer = global.new_balancers[balancer_id]

    local belts, lanes
    if input then
        belts = balancer.input_belts
        lanes = balancer.input_lanes
    else
        belts = balancer.output_belts
        lanes = balancer.output_lanes
    end

    belts[belt.unit_number] = belt

    if lane_ids then
        for _, id in pairs(lane_ids) do
            local transport_line = belt.get_transport_line(id)
            table.insert(lanes, transport_line)
        end
    else
        local max_transport_line_index = 0
        if belt_type == "belt" then
            max_transport_line_index = belt.get_max_transport_line_index()
        elseif belt_type == "underground" then
            max_transport_line_index = 2
        end

        for i = 1, max_transport_line_index do
            local transport_line = belt.get_transport_line(i)
            table.insert(lanes, transport_line)
        end
    end

    -- update nth_tick
    balancer_recalculate_nth_tick(balancer_id)
end

---balancer_remove_belt
---remove belt from input/output and also remove related lanes
---@param balancer_id number balancer to perform on
---@param belt LuaEntity the belt to remove from input/output
---@param input boolean true if input, false if output
function balancer_remove_belt(balancer_id, belt, input)
    local balancer = global.new_balancers[balancer_id]

    if input then
        balancer.input_belts[belt.unit_number] = nil

        for i = 1, belt.get_max_transport_line_index() do
            remove_from_table(balancer.input_lanes, belt.get_transport_line(i))
        end
    else
        balancer.output_belts[belt.unit_number] = nil

        for i = 1, belt.get_max_transport_line_index() do
            remove_from_table(balancer.output_lanes, belt.get_transport_line(i))
        end
    end

    balancer_recalculate_nth_tick(balancer_id)
end

---balancer_merge_balancer
---merge other_balancer into the balancer
---@param balancer_id number balancer to perform on
---@param other_balancer_id number balancer that has to merge into this one
function balancer_merge_balancer(balancer_id, other_balancer_id)
    local balancer = global.new_balancers[balancer_id]
    local other_balancer = global.new_balancers[other_balancer_id]

    -- move splitters
    for _, splitter in pairs(other_balancer.splitter) do
        if splitter.valid then
            balancer.splitter[splitter.unit_number] = splitter
        end
    end

    -- move belts
    for key, belt in pairs(other_balancer.input_belts) do
        if belt.valid then
            balancer.input_belts[key] = belt
        end
    end
    for key, belt in pairs(other_balancer.output_belts) do
        if belt.valid then
            balancer.output_belts[key] = belt
        end
    end

    -- move belts
    for _, lane in pairs(other_balancer.input_lanes) do
        if lane.valid then
            table.insert(balancer.input_lanes, lane)
        end
    end
    for _, lane in pairs(other_balancer.output_lanes) do
        if lane.valid then
            table.insert(balancer.output_lanes, lane)
        end
    end

    -- move buffer
    for _, item in pairs(other_balancer.buffer) do
        table.insert(balancer.buffer, item)
    end

    global.new_balancers[other_balancer_id] = nil

    unregister_on_tick(other_balancer_id)
    balancer_recalculate_nth_tick(balancer_id)
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

---balancer_has_splitter
---check if given balancer holds a specific splitter
---@param balancer_id number balancer to perform on
---@param splitter LuaEntity splitter to
---@return boolean true if splitter is hold by balancer
function balancer_has_splitter(balancer_id, splitter)
    local balancer = global.new_balancers[balancer_id]

    for _, self_splitter in pairs(balancer.splitter) do
        if self_splitter.valid and splitter.unit_number == self_splitter.unit_number then
            return true
        end
    end
    return false
end

---is_valid
---@return boolean true if balancer is valid
function balancer_is_valid(balancer_id)
    local balancer = global.new_balancers[balancer_id]

    if table_size(balancer.splitter) > 0 then
        return true
    end
    return false
end

---balancer_on_tick
---Run the complete Logic from moving objects from input to buffer and from buffer to output
---@param balancer_id number balancer to perform on
function balancer_on_tick(balancer_id, tick)
    local balancer = global.new_balancers[balancer_id]

    if #balancer.input_lanes > 0 and #balancer.output_lanes > 0 then
        local last_one_failed = 0

        -- get how many items are needed per lane
        local buffer_count = #balancer.buffer
        local output_lane_count = #balancer.output_lanes
        local gather_amount = output_lane_count - buffer_count

        -- INPUT
        while gather_amount > 0 do
            if last_one_failed == balancer.current_input_lane then
                break
            end

            local lane = balancer.input_lanes[balancer.current_input_lane]
            if lane and lane.valid then
                if #lane > 0 then
                    -- remove item from lane and add to buffer
                    local lua_item = lane[1]
                    local simple_item = convert_LuaItemStack_to_SimpleItemStack(lua_item)
                    lane.remove_item(lua_item)
                    table.insert(balancer.buffer, simple_item)
                    gather_amount = gather_amount - 1
                    last_one_failed = 0
                else
                    if last_one_failed == 0 then
                        last_one_failed = balancer.current_input_lane
                    end
                end
            end
            balancer.current_input_lane = balancer.current_input_lane + 1
            balancer.current_input_lane = ((balancer.current_input_lane - 1) % #balancer.input_lanes) + 1
        end

        -- OUTPUT
        for i = 1, #balancer.output_lanes do
            if #balancer.buffer > 0 then
                local lane = balancer.output_lanes[balancer.current_output_lane]
                if lane and lane.valid and lane.can_insert_at_back() then
                    if lane.insert_at_back(balancer.buffer[1]) then
                        table.remove(balancer.buffer, 1)
                    end
                end

                balancer.current_output_lane = balancer.current_output_lane + 1
                balancer.current_output_lane = ((balancer.current_output_lane - 1) % #balancer.output_lanes) + 1
            else
                break
            end
        end
    end
end

---balancer_get_linked
---get all lined splitters into an array of LuaEntity
---@param balancer_id number balancer to perform on
---@return LuaEntity[]
function balancer_get_linked(balancer_id)
    local balancer = global.new_balancers[balancer_id]

    -- create matrix
    local matrix = {}
    for _, splitter in pairs(balancer.splitter) do
        if splitter and splitter.valid then
            local pos = splitter.position
            if not matrix[pos.x] then
                matrix[pos.x] = {}
            end
            matrix[pos.x][pos.y] = splitter

        end
    end

    local curr_num = 0
    local result = {}
    repeat
        curr_num = curr_num + 1
        balancer_expand_first(matrix, curr_num, result)
    until (table_size(matrix) == 0)
    return result
end

---balancer_expand_first
---expand the first found not expanded Element in the matrix
---@param matrix LuaEntity[][] matrix to perform logic on
---@param num number
function balancer_expand_first(matrix, num, result)
    for x_key, _ in pairs(matrix) do
        local breaker = false
        for y_key, _ in pairs(matrix[x_key]) do
            if matrix[x_key][y_key] then
                result[num] = {}
                balancer_expand_matrix(matrix, { x = x_key, y = y_key }, num, result)
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
function balancer_expand_matrix(matrix, pos, num, result)
    if matrix[pos.x] and matrix[pos.x][pos.y] then
        local splitter = matrix[pos.x][pos.y]
        result[num][splitter.unit_number] = splitter
        matrix[pos.x][pos.y] = nil
        if table_size(matrix[pos.x]) == 0 then
            matrix[pos.x] = nil
        end

        balancer_expand_matrix(matrix, { x = pos.x - 1, y = pos.y }, num, result)
        balancer_expand_matrix(matrix, { x = pos.x + 1, y = pos.y }, num, result)
        balancer_expand_matrix(matrix, { x = pos.x, y = pos.y - 1 }, num, result)
        balancer_expand_matrix(matrix, { x = pos.x, y = pos.y + 1 }, num, result)
    end
end
