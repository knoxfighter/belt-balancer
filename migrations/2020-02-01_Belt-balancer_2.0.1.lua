if settings.startup["bobmods-logistics-beltoverhaul"].value == true then
    -- on boblogistics is already there
    for _, force in pairs(game.forces) do
        local technologies = force.technologies
        local recipes = force.recipes

        technologies["belt-balancer-0"].researched = technologies["belt-balancer-1"].researched
        recipes["belt-balancer-basic-belt"].enabled = technologies["belt-balancer-1"].researched
    end
end
