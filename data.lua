data:extend {
    {
        type = "simple-entity-with-force",
        name = "belt-balancer",
        icon = "__belt-balancer__/graphics/icons/balancer.png",
        icon_size = 200,
        flags = { "placeable-neutral", "player-creation" },
        minable = { mining_time = 0.1, result = "belt-balancer" },
        max_health = 170,
        corpse = "splitter-remnants",
        resistances = {
            {
                type = "fire",
                percent = 60
            }
        },
        collision_box = { { -0.35, -0.35 }, { 0.35, 0.35 } },
        selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        render_layer = "object",
        animations = {
            {
                filename = "__belt-balancer__/graphics/entities/balancer.png",
                priority = "high",
                width = 200,
                height = 200,
                frame_count = 16,
                line_length = 8,
                scale = 0.25,
                animation_speed = 0.15,
                shift = util.by_pixel(0, -1)
            }
        },
    },
    {
        type = "item",
        name = "belt-balancer",
        icon = "__belt-balancer__/graphics/icons/balancer.png",
        icon_size = 200,
        subgroup = "belt",
        order = "c[splitter]-x[balancer]",
        place_result = "belt-balancer",
        stack_size = 50
    },
    {
        type = "recipe",
        name = "belt-balancer-normal-belt",
        enabled = false,
        energy_required = 3,
        ingredients = {
            { "iron-gear-wheel", 20 },
            { "electronic-circuit", 15 },
            { "transport-belt", 5 },
        },
        result = "belt-balancer",
        order = "d[balancer]-a[balancer]"
    },
    {
        type = "recipe",
        name = "belt-balancer-fast-belt",
        enabled = false,
        energy_required = 2.5,
        ingredients = {
            { "iron-gear-wheel", 20 },
            { "electronic-circuit", 15 },
            { "fast-transport-belt", 5 },
        },
        results = {
            { "belt-balancer", 2 }
        },
        order = "d[balancer]-b[balancer]"
    },
    {
        type = "recipe",
        name = "belt-balancer-express-belt",
        enabled = false,
        energy_required = 2,
        ingredients = {
            { "iron-gear-wheel", 20 },
            { "electronic-circuit", 15 },
            { "express-transport-belt", 5 },
        },
        results = {
            { "belt-balancer", 3 }
        },
        order = "d[balancer]-c[balancer]"
    },
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
                recipe = "belt-balancer-normal-belt",
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
                recipe = "belt-balancer-normal-belt",
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
