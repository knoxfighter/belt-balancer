require("objects.balancer")

-- reload all balancers

-- clear global tables
global.belt_balancer_max_id = 0
global.new_balancers = nil
global.new_balancers = {}
global.events = nil
global.events = {}

-- rebuild global tables with all existing balancers
for _, surface in pairs(game.surfaces) do
    local all_balancer = surface.find_entities_filtered { name = { "belt-balancer" } }
    for i = 1, #all_balancer do
        entity_created({entity = all_balancer[i]})
    end
end
