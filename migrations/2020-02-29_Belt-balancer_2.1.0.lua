-- remove old values
global.belt_balancer_max_id = nil
global.new_balancers = nil
global.events = nil

-- set defaults and initialize values in global table
global.next_balancer_unit_number = 1
global.next_lane_unit_number = 1
global.balancer = {}
global.parts = {}
global.belts = {}
global.lanes = {}
global.events = {}

-- rebuild global tables with all existing balancers
for _, surface in pairs(game.surfaces) do
    local all_balancer = surface.find_entities_filtered { name = { "balancer-part" } }
    for i = 1, #all_balancer do
        built_entity({ entity = all_balancer[i]})
    end
end
