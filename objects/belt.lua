belt_functions = {}

---get belt, if not yet in global table, create it...
---The Balancer is not added to the input/output tacker!
---@param belt_entity LuaEntity
---@return Belt The found or created belt
function belt_functions.get_or_create(belt_entity)
    -- find belt in global stack
    local global_belt = global.belts[belt_entity.unit_number]
    if global_belt then
        return global_belt
    end

    ---@type Belt
    local belt = {}

    belt.entity = belt_entity
    belt.type = belt_entity.type
    belt.position = belt_entity.position
    belt.direction = belt_entity.direction
    belt.surface = belt_entity.surface
    belt.output_balancer = {}
    belt.input_balancer = {}

    -- only run over 2 lanes, if underground-belt
    local belt_count
    if belt_entity.type == "underground-belt" then
        belt_count = 2
    else
        belt_count = belt_entity.get_max_transport_line_index()
    end

    -- create list of lanes of this belt in global stack
    belt.lanes = {}
    for i = 1, belt_count do
        local index = get_next_lane_unit_number()
        local transport_line = belt_entity.get_transport_line(i)
        global.lanes[index] = transport_line
        belt.lanes[i] = index
    end

    global.belts[belt_entity.unit_number] = belt

    return belt
end

---get_input_output_pos
---get the positions where the belt will transport items from and to
---@param belt LuaEntity the belt to calculate on
---@param direction defines.direction override the direction of the belt. if nil will use belt.direction (has to be used if belt is invalid!!)
---@param position Position override the position of the belt. if nil will use belt.position (has to be used if belt is invalid!!)
---@return Position,Position return the positions (into, from)
function belt_functions.get_input_output_pos(belt, direction, position)
    position = position or belt.position
    direction = direction or belt.direction
    local into_pos, from_pos

    if direction == defines.direction.north then
        into_pos = { x = position.x, y = position.y - 1 }
        from_pos = { x = position.x, y = position.y + 1 }
    elseif direction == defines.direction.south then
        into_pos = { x = position.x, y = position.y + 1 }
        from_pos = { x = position.x, y = position.y - 1 }
    elseif direction == defines.direction.west then
        into_pos = { x = position.x - 1, y = position.y }
        from_pos = { x = position.x + 1, y = position.y }
    elseif direction == defines.direction.east then
        into_pos = { x = position.x + 1, y = position.y }
        from_pos = { x = position.x - 1, y = position.y }
    end

    return into_pos, from_pos
end

---get_input_output_pos_splitter
---get the positions where the splitter will transport items from and to
---@param splitter LuaEntity the splitter to calculate on
---@param direction defines.direction override the direction of the belt. if nil will use belt.direction
---@param position Position override the position of the belt. if nil will use belt.position (has to be used if belt is invalid!!)
---@return Get_input_output_pos_splitter_result[],Get_input_output_pos_splitter_result[] returns array of positions and belt-lanes (into, from).
function belt_functions.get_input_output_pos_splitter(splitter, direction, position)
    local splitter_pos = position or splitter.position
    direction = direction or splitter.direction
    ---@type Get_input_output_pos_splitter_result[]
    local into_pos = {}
    ---@type Get_input_output_pos_splitter_result[]
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

---finds the parts, that the belt has as input/output
---@param belt LuaEntity the belt to search from
---@param direction defines.direction override the direction of the belt.
---@param surface LuaSurface override the surface of the entity. if nil will use belt.surface. (has to be used, when belt-entity is invalid!!)
---@param position Position override the position of the entity. if nil will use belt.position. (has to be used, when belt-entity is invalid!!)
---@return Part,Part into_part, from_part
function belt_functions.get_input_output_parts(belt, direction, surface, position)
    surface = surface or belt.surface
    position = position or belt.position

    local into_pos, from_pos = belt_functions.get_input_output_pos(belt, direction, position)

    local into_part, from_part

    local into_entity = surface.find_entity("balancer-part", into_pos)
    if into_entity then
        into_part = part_functions.get_or_create(into_entity)
    end

    local from_entity = surface.find_entity("balancer-part", from_pos)
    if from_entity then
        from_part = part_functions.get_or_create(from_entity)
    end

    return into_part, from_part
end

---finds the parts, that the splitter has as input/output
---@param splitter LuaEntity the splitter to search from
---@param direction defines.direction override the direction of the splitter.
---@param surface LuaSurface override the surface of the splitter. if nil will use belt.surface. (has to be used, when belt-entity is invalid!!)
---@param position Position override the position of the splitter. if nil will use belt.position. (has to be used, when belt-entity is invalid!!)
---@return Get_input_output_parts_splitter_result[],Get_input_output_parts_splitter_result[] into_parts, from_parts
function belt_functions.get_input_output_parts_splitter(splitter, direction, surface, position)
    surface = surface or splitter.surface

    local into_positions, from_positions = belt_functions.get_input_output_pos_splitter(splitter, direction, position)

    ---@type Get_input_output_parts_splitter_result[]
    local into_parts = {}
    ---@type Get_input_output_parts_splitter_result[]
    local from_parts = {}

    for _, into_position in pairs(into_positions) do
        local into_entity = surface.find_entity("balancer-part", into_position.position)
        if into_entity then
            ---@type Get_input_output_parts_splitter_result
            local into_part = into_position

            into_part.part = part_functions.get_or_create(into_entity)
            table.insert(into_parts, into_part)
        end
    end

    for _, from_position in pairs(from_positions) do
        local from_entity = surface.find_entity("balancer-part", from_position.position)
        if from_entity then
            ---@type Get_input_output_parts_splitter_result
            local from_part = from_position

            from_part.part = part_functions.get_or_create(from_entity)
            table.insert(from_parts, from_part)
        end
    end

    return into_parts, from_parts
end

---This is the functionality to call, when a new belt-entity is created
---@param belt LuaEntity The belt, that is being created
function belt_functions.built_belt(belt)
    -- get nearby balancer
    local into_part, from_part = belt_functions.get_input_output_parts(belt)

    if belt.type == "underground-belt" then
        if belt.belt_to_ground_type == "input" then
            into_part = nil
        elseif belt.belt_to_ground_type == "output" then
            from_part = nil
        end
    end

    if into_part then
        local stack_belt = belt_functions.get_or_create(belt)

        --add balancer to belt
        stack_belt.output_balancer[into_part.balancer] = into_part.balancer

        --add belt to part
        into_part.input_belts[belt.unit_number] = belt.unit_number

        local balancer = global.balancer[into_part.balancer]
        for _, lane in pairs(stack_belt.lanes) do
            -- add lanes to balancer
            balancer.input_lanes[lane] = global.lanes[lane]
            -- add lanes to part
            into_part.input_lanes[lane] = global.lanes[lane]
        end

        -- recalculate nth_tick on changed balancer
        balancer_functions.recalculate_nth_tick(balancer.unit_number)
    end

    if from_part then
        local stack_belt = belt_functions.get_or_create(belt)

        --add balancer to belt
        stack_belt.input_balancer[from_part.balancer] = from_part.balancer

        --add belt to part
        from_part.output_belts[belt.unit_number] = belt.unit_number

        local balancer = global.balancer[from_part.balancer]
        for _, lane in pairs(stack_belt.lanes) do
            -- add lanes to balancer
            balancer.output_lanes[lane] = global.lanes[lane]
            -- add lanes to part
            from_part.output_lanes[lane] = global.lanes[lane]
        end

        -- recalculate nth_tick on changed balancer
        balancer_functions.recalculate_nth_tick(balancer.unit_number)
    end
end

---This is the functionality to call, when a new splitter-entity is created
---@param splitter_entity LuaEntity
function belt_functions.built_splitter(splitter_entity)
    local into_parts, from_parts = belt_functions.get_input_output_parts_splitter(splitter_entity)

    for _, into_part in pairs(into_parts) do
        local stack_belt = belt_functions.get_or_create(splitter_entity)

        --add balancer to belt
        stack_belt.output_balancer[into_part.part.balancer] = into_part.part.balancer

        --add belt to part
        into_part.part.input_belts[splitter_entity.unit_number] = splitter_entity.unit_number

        local balancer = global.balancer[into_part.part.balancer]
        for lane_i, _ in pairs(into_part.lanes) do
            local lane = stack_belt.lanes[lane_i]

            --add lanes to balancer
            balancer.input_lanes[lane] = global.lanes[lane]
            --add lanes to part
            into_part.part.input_lanes[lane] = global.lanes[lane]
        end

        -- recalculate nth_tick on changed balancer
        balancer_functions.recalculate_nth_tick(balancer.unit_number)
    end

    for _, from_part in pairs(from_parts) do
        local stack_belt = belt_functions.get_or_create(splitter_entity)

        --add balancer to belt
        stack_belt.input_balancer[from_part.part.balancer] = from_part.part.balancer

        --add belt to part
        from_part.part.output_belts[splitter_entity.unit_number] = splitter_entity.unit_number

        local balancer = global.balancer[from_part.part.balancer]
        for lane_i, _ in pairs(from_part.lanes) do
            local lane = stack_belt.lanes[lane_i]
            --add lanes to balancer
            balancer.output_lanes[lane] = global.lanes[lane]

            --add lanes to part
            from_part.part.output_lanes[lane] = global.lanes[lane]
        end

        -- recalculate nth_tick on changed balancer
        balancer_functions.recalculate_nth_tick(balancer.unit_number)
    end
end

---@param entity LuaEntity The entity that got removed
---@param direction defines.direction override the direction of removal
---@param unit_number uint override the belts unit_number, this works on (has to be used, when entity is invalid!!)
---@param surface LuaSurface override the surface of the belt. (has to be used, when entity is invalid!!)
---@param position Position override the position of the belt. (has to be used, when entity is invalid!!)
function belt_functions.remove_belt(entity, direction, unit_number, surface, position)
    unit_number = unit_number or entity.unit_number
    surface = surface or entity.surface
    position = position or entity.position

    -- check if belt is tracked
    local belt = global.belts[unit_number]
    if not belt then
        return
    end

    -- remove lanes from global stack
    for _, lane in pairs(belt.lanes) do
        global.lanes[lane] = nil
    end

    -- remove belt from global stack
    global.belts[unit_number] = nil

    -- find input_output balancer
    local into_part, from_part = belt_functions.get_input_output_parts(entity, direction, surface, position)

    if into_part then
        -- remove belt from part
        into_part.input_belts[unit_number] = nil

        local balancer = global.balancer[into_part.balancer]
        for _, lane in pairs(belt.lanes) do
            -- remove lanes from balancer
            balancer.input_lanes[lane] = nil
            -- remove lanes from part
            into_part.input_lanes[lane] = nil
        end
    end

    if from_part then
        -- remove belt from part
        from_part.output_belts[unit_number] = nil

        local balancer = global.balancer[from_part.balancer]
        for _, lane in pairs(belt.lanes) do
            -- remove lanes from balancer
            balancer.output_lanes[lane] = nil
            -- remove lanes from part
            from_part.output_lanes[lane] = nil
        end
    end

    -- recalculate_nth_tick
    if into_part then
        balancer_functions.recalculate_nth_tick(into_part.balancer)
    end
    if from_part then
        balancer_functions.recalculate_nth_tick(from_part.balancer)
    end
end

---@param entity LuaEntity
---@param direction defines.direction override the direction
---@param unit_number uint override the splitters unit_number, this works on (has to be used, when entity is invalid!!)
---@param surface LuaSurface override the surface of the splitter. (has to be used, when entity is invalid!!)
---@param position Position override the position of the splitter. (has to be used, when entity is invalid!!)
function belt_functions.remove_splitter(entity, direction, unit_number, surface, position)
    unit_number = unit_number or entity.unit_number

    -- check if splitter is tracked
    local belt = global.belts[unit_number]
    if not belt then
        return
    end

    -- remove lanes from global stack
    for _, lane in pairs(belt.lanes) do
        global.lanes[lane] = nil
    end

    -- remove belt from global stack
    global.belts[unit_number] = nil

    local into_parts, from_parts = belt_functions.get_input_output_parts_splitter(entity, direction, surface, position)
    for _, part in pairs(into_parts) do
        -- remove belt from part
        part.part.input_belts[unit_number] = nil

        local balancer = global.balancer[part.part.balancer]
        for _, lane in pairs(belt.lanes) do
            -- remove lanes from balancer
            balancer.input_lanes[lane] = nil
            -- remove lanes from part
            part.part.input_lanes[lane] = nil
        end
    end

    for _, part in pairs(from_parts) do
        -- remove belt from part
        part.part.output_belts[unit_number] = nil

        local balancer = global.balancer[part.part.balancer]
        for _, lane in pairs(belt.lanes) do
            -- remove lanes from balancer
            balancer.output_lanes[lane] = nil
            -- remove lanes from part
            part.part.output_lanes[lane] = nil
        end
    end

    -- recalculate_nth_tick
    for _, part in pairs(into_parts) do
        balancer_functions.recalculate_nth_tick(part.part.balancer)
    end
    for _, part in pairs(from_parts) do
        balancer_functions.recalculate_nth_tick(part.part.balancer)
    end
end

---check if this belt has to be tracked (is attached to balancer)
---If not, then remove the belt and its lanes from the global stack
---@param belt_index uint The belt to check
function belt_functions.check_track(belt_index)
    local belt = global.belts[belt_index]
    if table_size(belt.input_balancer) == 0 and table_size(belt.output_balancer) == 0 then
        -- belt is not needed
        -- remove lanes from global stack
        for _, lane in pairs(belt.lanes) do
            global.lanes[lane] = nil
        end

        -- remove belt from global stack
        global.belts[belt_index] = nil

    end
end

return belt_functions
