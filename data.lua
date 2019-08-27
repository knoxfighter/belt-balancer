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
    }
}

table.insert(data.raw.technology["logistics"].effects, { recipe = "belt-balancer-normal-belt", type = "unlock-recipe" })
table.insert(data.raw.technology["logistics-2"].effects, { recipe = "belt-balancer-fast-belt", type = "unlock-recipe" })
table.insert(data.raw.technology["logistics-3"].effects, { recipe = "belt-balancer-express-belt", type = "unlock-recipe" })
