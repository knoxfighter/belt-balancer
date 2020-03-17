local function clear_belt_table(tab)
    local to_remove = {}
    for _, belt_index in pairs(tab) do
        local belt = global.belts[belt_index]
        if not belt then
            table.insert(to_remove, belt_index)
        end
    end
    for _, remove_index in pairs(to_remove) do
        tab[remove_index] = nil
    end
end

local function clear_lane_table(tab)
    local to_remove = {}
    for _, lane_index in pairs(tab) do
        local lane = global.lanes[lane_index]
        if not lane then
            table.insert(to_remove, lane_index)
        end
    end
    for _, remove_index in pairs(to_remove) do
        tab[remove_index] = nil
    end
end

-- clear all unknown belts and lanes from parts
for _, part in pairs(global.parts) do
    clear_belt_table(part.input_belts)
    clear_belt_table(part.output_belts)
    clear_lane_table(part.input_lanes)
    clear_lane_table(part.output_lanes)
end

-- recreate all splitters
for _, surface in pairs(game.surfaces) do
    local splitters = surface.find_entities_filtered{type = "splitter"}
    for _, splitter in pairs(splitters) do
        belt_functions.built_splitter(splitter)
    end
end
