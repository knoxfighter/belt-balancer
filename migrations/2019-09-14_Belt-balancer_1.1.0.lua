for _, force in pairs(game.forces) do
    local technologies = force.technologies
    local recipes = force.recipes

    technologies["belt-balancer-1"].researched = recipes["belt-balancer-normal-belt"].enabled
    technologies["belt-balancer-2"].researched = recipes["belt-balancer-fast-belt"].enabled
    technologies["belt-balancer-3"].researched = recipes["belt-balancer-express-belt"].enabled
end