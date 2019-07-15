require("helper/message-handler")
require("objects/balancer")

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity},
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
            local belt = e.created_entity

            local into_balancer_index, from_balancer_index = get_input_output_balancer_index(belt)
            if into_balancer_index then
                balancer_add_belt(into_balancer_index, belt, true)
            end
            if from_balancer_index then
                balancer_add_belt(from_balancer_index, belt, false)
            end
        end
    end
)

script.on_event({defines.events.on_entity_died, defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity},
    function(e)
        if e.entity.name == "belt-balancer" then
            local removed_splitter = e.entity

            local balancer_index = find_belonging_balancer(removed_splitter)
            balancer_remove_splitter(balancer_index, removed_splitter)
            if not balancer_is_valid(balancer_index) then
                global.new_balancers[balancer_index] = nil
                unregister_on_tick(balancer_index)
                return
            end

            local linked_splitter = balancer_get_linked(balancer_index)
            if table_size(linked_splitter) > 1 then
                -- create multiple new balancers
                for _, splitter_group in pairs(linked_splitter) do
                    new_balancer(splitter_group)
                end
                global.new_balancers[balancer_index] = nil
                unregister_on_tick(balancer_index)
            end
        end

        if e.entity.type == "transport-belt" then
            local belt = e.entity
            local into_balancer_index, from_balancer_index = get_input_output_balancer_index(belt)

            if into_balancer_index then
                balancer_remove_belt(into_balancer_index, belt, true)
            end
            if from_balancer_index then
                balancer_remove_belt(from_balancer_index, belt, false)
            end
        end
    end
)

script.on_event({defines.events.on_player_rotated_entity},
    function(e)
        if e.entity.type == "transport-belt" then
            local belt = e.entity

            -- remove from balancers
            local into_balancer_index, from_balancer_index = get_input_output_balancer_index(belt, e.previous_direction)
            if into_balancer_index then
                balancer_remove_belt(into_balancer_index, belt, true)
            end
            if from_balancer_index then
                balancer_remove_belt(from_balancer_index, belt, false)
            end

            -- add to new balancers
            local into_balancer_index, from_balancer_index = get_input_output_balancer_index(belt)
            if into_balancer_index then
                balancer_add_belt(into_balancer_index, belt, true)
            end
            if from_balancer_index then
                balancer_add_belt(from_balancer_index, belt, false)
            end
        end
    end
)

-- on new savegame and on adding mod to existing save
script.on_init(function()
    global.belt_balancer_max_id = 0

    global.new_balancers = {}
    global.events = {}
end)

-- If some mod is changed, so train-stops are not valid anymore ... also reload
--script.on_configuration_changed()

script.on_load(reregister_on_tick)
