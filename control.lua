require("helper/message-handler")
require("objects/balancer")

function add_belt(belt)
    local into_balancer_index, from_balancer_index = get_input_output_balancer_index(belt)
    if into_balancer_index then
        balancer_add_belt(into_balancer_index, belt, true)
    end
    if from_balancer_index then
        balancer_add_belt(from_balancer_index, belt, false)
    end
end
function add_underground_belt(underground_belt)
    -- get the input/output-index
    local into_balancer_index, from_balancer_index = get_input_output_balancer_index(underground_belt)

    -- underground-belts only need one direction to work with
    if underground_belt.belt_to_ground_type == "output" and into_balancer_index then
        balancer_add_belt(into_balancer_index, underground_belt, true, "underground")
    elseif underground_belt.belt_to_ground_type == "input" and from_balancer_index then
        balancer_add_belt(from_balancer_index, underground_belt, false, "underground")
    end
end
function add_splitter_belt(splitter)
    local into_pos, from_pos = get_input_output_pos_splitter(splitter)
    for _, into in pairs(into_pos) do
        local balancer_id = get_balancer_index_from_pos(splitter.surface, into.position)
        if balancer_id then
            balancer_add_belt(balancer_id, splitter, true, "splitter", into.lanes)
        end
    end
    for _, from in pairs(from_pos) do
        local balancer_id = get_balancer_index_from_pos(splitter.surface, from.position)
        if balancer_id then
            balancer_add_belt(balancer_id, splitter, false, "splitter", from.lanes)
        end
    end
end
function remove_belt(belt, direction)
    -- remove from balancers
    local into_balancer_index, from_balancer_index = get_input_output_balancer_index(belt, direction)
    if into_balancer_index then
        balancer_remove_belt(into_balancer_index, belt, true)
    end
    if from_balancer_index then
        balancer_remove_belt(from_balancer_index, belt, false)
    end
end
function remove_splitter_belt(splitter, direction)
    local into, from = get_input_output_pos_splitter(splitter, direction)

    for _, into_single in pairs(into) do
        local balancer_id = get_balancer_index_from_pos(splitter.surface, into_single.position)
        if balancer_id then
            balancer_remove_belt(balancer_id, splitter, false)
        end
    end

    for _, from_single in pairs(from) do
        local balancer_id = get_balancer_index_from_pos(splitter.surface, from_single.position)
        if balancer_id then
            balancer_remove_belt(balancer_id, splitter, true)
        end
    end
end

script.on_event({ defines.events.on_built_entity, defines.events.on_robot_built_entity },
    function(e)
        if e.created_entity.name == "belt-balancer" then
            local placed_splitter = e.created_entity

            local nearby_balancer_indices = find_nearby_balancer(placed_splitter)
            local nearby_balancer_amount = table_size(nearby_balancer_indices)

            if nearby_balancer_amount == 0 then
                -- create new balancer
                new_balancer(placed_splitter)
            elseif nearby_balancer_amount == 1 then
                -- add to existing balancer
                for _, nearby_balancer_index in pairs(nearby_balancer_indices) do
                    balancer_add_splitter(nearby_balancer_index, placed_splitter)
                end
            elseif nearby_balancer_amount >= 2 then
                -- add to existing balancer and merge them
                local base_balancer_index
                for _, nearby_balancer_index in pairs(nearby_balancer_indices) do
                    if not base_balancer_index then
                        base_balancer_index = nearby_balancer_index

                        -- add splitter to balancer
                        balancer_add_splitter(base_balancer_index, placed_splitter)
                    else
                        -- merge balancer and remove them from global table
                        balancer_merge_balancer(base_balancer_index, nearby_balancer_index)
                    end
                end
            end
        end

        if e.created_entity.type == "transport-belt" then
            add_belt(e.created_entity)
        end

        if e.created_entity.type == "underground-belt" then
            add_underground_belt(e.created_entity)
        end

        if e.created_entity.type == "splitter" then
            add_splitter_belt(e.created_entity)
        end
    end
)

script.on_event({ defines.events.on_entity_died, defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity },
    function(e)
        if e.entity.name == "belt-balancer" then
            local removed_splitter = e.entity

            local balancer_index = find_belonging_balancer(removed_splitter)
            balancer_remove_splitter(balancer_index, removed_splitter)
            if not balancer_is_valid(balancer_index) then
                -- give player buffer items
                if e.name == defines.events.on_player_mined_entity or e.name == defines.events.on_robot_mined_entity then
                    for _, item in pairs(global.new_balancers[balancer_index].buffer) do
                        e.buffer.insert(item)
                    end
                end

                -- delete balancer
                global.new_balancers[balancer_index] = nil
                unregister_on_tick(balancer_index)
                return
            end

            local linked_splitter = balancer_get_linked(balancer_index)
            if table_size(linked_splitter) > 1 then
                -- give player buffer items
                if e.name == defines.events.on_player_mined_entity or e.name == defines.events.on_robot_mined_entity then
                    for _, item in pairs(global.new_balancers[balancer_index].buffer) do
                        e.buffer.insert(item)
                    end
                end

                -- create multiple new balancers
                for _, splitter_group in pairs(linked_splitter) do
                    new_balancer(splitter_group)
                end
                global.new_balancers[balancer_index] = nil
                unregister_on_tick(balancer_index)
            end
        end

        if e.entity.type == "transport-belt" or e.entity.type == "underground-belt" then
            remove_belt(e.entity)
        end

        if e.entity.type == "splitter" then
            remove_splitter_belt(e.entity)
        end
    end
)

script.on_event({ defines.events.on_player_rotated_entity },
    function(e)
        if e.entity.type == "transport-belt" then
            remove_belt(e.entity, e.previous_direction)
            add_belt(e.entity)
        end

        if e.entity.type == "underground-belt" then
            remove_belt(e.entity, e.previous_direction)
            add_underground_belt(e.entity)
            -- Neighbour is only the other end
            local neighbour = e.entity.neighbours
            if neighbour and neighbour.valid then
                -- make neighbour also have previous_direction
                local previous_direction = (neighbour.direction + 4) % 8
                remove_belt(neighbour, previous_direction)
                add_belt(neighbour)
            end
        end

        if e.entity.type == "splitter" then
            remove_splitter_belt(e.entity, e.previous_direction)
            add_splitter_belt(e.entity)
        end
    end
)

-- on new savegame and on adding mod to existing save
script.on_init(function()
    global.belt_balancer_max_id = 0

    global.new_balancers = {}
    global.events = {}

    -- Unlock recipes, if technologies already researched
    for _, force in pairs(game.forces) do
        if force.technologies["logistics"].researched then
            force.recipes["belt-balancer-normal-belt"].enabled = true
        end
        if force.technologies["logistics-2"].researched then
            force.recipes["belt-balancer-fast-belt"].enabled = true
        end
        if force.technologies["logistics-3"].researched then
            force.recipes["belt-balancer-express-belt"].enabled = true
        end
    end
end)

-- If some mod is changed, so train-stops are not valid anymore ... also reload
--script.on_configuration_changed()

script.on_load(reregister_on_tick)
