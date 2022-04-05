part_functions = {}

---built
---@param entity LuaEntity The part-entity, that is built
function part_functions.built(entity)
    --create new Part Object from Part Entity
    --This will also create/merge the underlying balancer object
    local part = part_functions.get_or_create(entity)
end

---creates new Part from entity
---This will also create the Belt-objects for this part
---Also the Balancer is created, when none is there.
---@param entity LuaEntity The balancer-part entity
---@return Part
function part_functions.get_or_create(entity)
    local global_part = global.parts[entity.unit_number]
    if global_part then
        return global_part
    end

    ---@type Part
    local part = {}

    part.entity = entity

    -- get balancer for this part
    part.balancer = balancer_functions.find_from_part(part)
    local balancer = global.balancer[part.balancer]

    -- find belts
    part.input_belts = {}
    part.output_belts = {}
    part.input_lanes = {}
    part.output_lanes = {}

    local input_belts, output_belts = part_functions.find_input_output_belts(entity)
    for _, input_belt in pairs(input_belts) do
        local belt_unit_number = input_belt.belt.unit_number

        -- get belt object from the stack
        local belt = belt_functions.get_or_create(input_belt.belt)

        -- Set balancer index in belt
        belt.output_balancer[balancer.unit_number] = balancer.unit_number

        -- set belt index to part
        part.input_belts[belt_unit_number] = belt_unit_number

        -- set used lanes to balancer and part objects
        if input_belt.lanes then
            for _, lane in pairs(input_belt.lanes) do
                local belt_lane = belt.lanes[lane]
                balancer.input_lanes[belt_lane] = global.lanes[belt_lane]
                part.input_lanes[belt_lane] = global.lanes[belt_lane]
            end
        else
            for _, v in pairs(belt.lanes) do
                balancer.input_lanes[v] = global.lanes[v]
                part.input_lanes[v] = global.lanes[v]
            end
        end
    end

    for _, output_belt in pairs(output_belts) do
        local belt_unit_number = output_belt.belt.unit_number

        -- get belt object from the stack
        local belt = belt_functions.get_or_create(output_belt.belt)

        -- Set balancer index in belt
        belt.input_balancer[balancer.unit_number] = balancer.unit_number

        -- set belt index to part
        part.output_belts[belt_unit_number] = belt_unit_number

        -- set used lanes to balancer and part objects
        if output_belt.lanes then
            for _, lane in pairs(output_belt.lanes) do
                local belt_lane = belt.lanes[lane]
                balancer.output_lanes[belt_lane] = global.lanes[belt_lane]
                part.output_lanes[belt_lane] = global.lanes[belt_lane]
            end
        else
            for _, lane in pairs(belt.lanes) do
                balancer.output_lanes[lane] = global.lanes[lane]
                part.output_lanes[lane] = global.lanes[lane]
            end
        end
    end

    -- set parts in global table
    global.parts[entity.unit_number] = part

    balancer_functions.recalculate_nth_tick(balancer.unit_number)

    return part
end

---find_nearby_parts
---Find nearby `belt-balancer` entities, then get the balancer, that they are in.
---This just finds the nearby `belt-balancer` entities and returns a list of them.
---The base entity is filtered out of the result array.
---@param entity LuaEntity The part-entity
---@return uint[] list of unit_numbers of found balancer
function part_functions.find_nearby_balancer(entity)
    local found_parts = entity.surface.find_entities_filtered {
        position = entity.position,
        name = "balancer-part",
        radius = 1,
    }

    ---@type uint[]
    local found_balancer = {}
    -- remove source from found_parts
    for _, found_part in ipairs(found_parts) do
        if found_part.unit_number ~= entity.unit_number then
            local part = global.parts[found_part.unit_number]
            if part then
                local balancer_id = part.balancer
                if balancer_id then
                    found_balancer[balancer_id] = balancer_id
                end
            end
        end
    end

    return found_balancer
end

---find_input_output_belts
---find input and output belts for this specific splitter
---@param balancer_part LuaEntity the balancer_part to search from
---@return table<uint, Find_input_output_belts_result>,table<uint, Find_input_output_belts_result> -- found input and output belts, with entity.unit_number as key
function part_functions.find_input_output_belts(balancer_part)
    local splitter_pos = balancer_part.position
    ---@type Find_input_output_belts_result
    local input_belts = {}
    ---@type Find_input_output_belts_result
    local output_belts = {}

    local found_belts = balancer_part.surface.find_entities_filtered {
        position = splitter_pos,
        type = "transport-belt",
        radius = 1
    }
    for _, belt in pairs(found_belts) do
        local into_pos, from_pos = belt_functions.get_input_output_pos(belt)
        if into_pos.x == splitter_pos.x and into_pos.y == splitter_pos.y then
            input_belts[belt.unit_number] = { belt = belt, belt_type = "belt" }
        elseif from_pos.x == splitter_pos.x and from_pos.y == splitter_pos.y then
            output_belts[belt.unit_number] = { belt = belt, belt_type = "belt" }
        end
    end

    local found_underground_belts = balancer_part.surface.find_entities_filtered {
        position = splitter_pos,
        type = "underground-belt",
        radius = 1
    }
    for _, underground_belt in pairs(found_underground_belts) do
        local into_pos, from_pos = belt_functions.get_input_output_pos(underground_belt)
        if underground_belt.belt_to_ground_type == "output" and into_pos.x == splitter_pos.x and into_pos.y == splitter_pos.y then
            input_belts[underground_belt.unit_number] = { belt = underground_belt, belt_type = "underground" }
        elseif underground_belt.belt_to_ground_type == "input" and from_pos.x == splitter_pos.x and from_pos.y == splitter_pos.y then
            output_belts[underground_belt.unit_number] = { belt = underground_belt, belt_type = "underground" }
        end
    end

    local found_splitter_belts = balancer_part.surface.find_entities_filtered {
        position = splitter_pos,
        type = "splitter",
        radius = 1.5
    }
    for _, splitter_belt in pairs(found_splitter_belts) do
        local into_pos, from_pos = belt_functions.get_input_output_pos_splitter(splitter_belt)
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

---This will remove the Part Entity. It will also split the balancer, after removing the Part
---@param entity LuaEntity The part that got removed
---@param buffer LuaInventory
function part_functions.remove(entity, buffer)
    local part = global.parts[entity.unit_number]
    local balancer = global.balancer[part.balancer]

    -- remove part from balancer
    balancer.parts[entity.unit_number] = nil

    -- remove part from global stack
    global.parts[entity.unit_number] = nil

    for _, belt_index in pairs(part.input_belts) do
        local belt = global.belts[belt_index]

        -- only remove lanes, if this is splitter
        if belt.type == "splitter" then
            local into_pos, _ = belt_functions.get_input_output_pos_splitter(belt.entity)
            for _, pos in pairs(into_pos) do
                local entity_pos = part.entity.position
                if entity_pos.x == pos.position.x and entity_pos.y == pos.position.y then
                    -- remove lanes from balancer
                    for _, lane_index in pairs(pos.lanes) do
                        local lane = belt.lanes[lane_index]
                        balancer.input_lanes[lane] = nil
                    end
                end
            end

            -- check if lanes are still in the balancer
            local found_lane = false
            for lane, _ in pairs(balancer.input_lanes) do
                if table.contains(belt.lanes, lane) then
                    found_lane = true
                    break
                end
            end

            -- when lane not found, remove balancer from belt
            if not found_lane then
                belt.output_balancer[part.balancer] = nil
            end
        else
            -- remove balancer from belt
            belt.output_balancer[part.balancer] = nil

            -- remove lanes from balancer
            for _, lane in pairs(belt.lanes) do
                balancer.input_lanes[lane] = nil
            end
        end

        -- check if belt is still attached to a part
        belt_functions.check_track(belt_index)
    end

    for _, belt_index in pairs(part.output_belts) do
        local belt = global.belts[belt_index]

        -- only remove lanes, if this is splitter
        if belt.type == "splitter" then
            local _, from_pos = belt_functions.get_input_output_pos_splitter(belt.entity)
            for _, pos in pairs(from_pos) do
                local entity_pos = part.entity.position
                if entity_pos.x == pos.position.x and entity_pos.y == pos.position.y then
                    -- remove lanes from balancer
                    for _, lane_index in pairs(pos.lanes) do
                        local lane = belt.lanes[lane_index]
                        balancer.output_lanes[lane] = nil
                    end
                end
            end

            -- check if lanes are still in the balancer
            local found_lane = false
            for lane, _ in pairs(balancer.output_lanes) do
                if table.contains(belt.lanes, lane) then
                    found_lane = true
                    break
                end
            end

            -- when lane not found, remove balancer from belt
            if not found_lane then
                belt.input_balancer[part.balancer] = nil
            end
        else
            -- remove balancer from belt
            belt.input_balancer[part.balancer] = nil

            -- remove lanes from balancer
            for _, lane in pairs(belt.lanes) do
                balancer.output_lanes[lane] = nil
            end
        end

        -- check if belt is still attached to a part
        belt_functions.check_track(belt_index)
    end

    -- recalculate nth_tick, if no part is there, this will unregister the balancer
    balancer_functions.recalculate_nth_tick(balancer.unit_number)

    ---@type Item_drop_param
    local drop_to = {
        buffer = buffer,
        position = entity.position,
        surface = entity.surface,
        force = entity.force
    }

    -- check if balancer is valid
    local check_track_result = balancer_functions.check_track(balancer.unit_number, drop_to)
    if check_track_result then
        -- check if balancer is still in one part
        balancer_functions.check_connected(balancer.unit_number, drop_to)
    end
end

return part_functions
