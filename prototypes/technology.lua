data:extend {
    {
        type = "technology",
        name = "belt-balancer-1",
        icon = "__belt-balancer__/graphics/icons/balancer.png",
        icon_size = 200,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "belt-balancer-normal-belt",
            }
        },
        prerequisites = { "logistics" },
        unit = {
            count = 20,
            ingredients = { { "automation-science-pack", 1 } },
            time = 15
        },
    },
    {
        type = "technology",
        name = "belt-balancer-2",
        icon = "__belt-balancer__/graphics/icons/balancer.png",
        icon_size = 200,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "belt-balancer-fast-belt",
            }
        },
        prerequisites = { "logistics-2", "belt-balancer-1" },
        unit = {
            count = 100,
            ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1}
            },
            time = 30
        },
    },
    {
        type = "technology",
        name = "belt-balancer-3",
        icon = "__belt-balancer__/graphics/icons/balancer.png",
        icon_size = 200,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "belt-balancer-express-belt",
            }
        },
        prerequisites = { "logistics-3", "belt-balancer-2" },
        unit = {
            count = 200,
            ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1}
            },
            time = 20
        },
    }
}