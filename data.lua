require("__base__.prototypes.entity.transport-belt-pictures")

data:extend {
    {
        type = "simple-entity-with-force",
        name = "belt-balancer",
        icon = "__belt-balancer__/graphics/icons/balancer.png",
        icon_size = 32,
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
        --pictures = {
        --    {
        --        filename = "__belt-balancer__/graphics/compound-splitter-lane.png",
        --        width = 61,
        --        height = 50,
        --        shift = { 0.078125, 0.15625 },
        --    }
        --},
    },
    {
        type = "item",
        name = "belt-balancer",
        icon = "__belt-balancer__/graphics/icons/balancer.png",
        icon_size = 200,
        subgroup = "belt",
        order = "c[splitter]-a[splitter]",
        place_result = "belt-balancer",
        stack_size = 50
    },
    {
        type = "recipe",
        name = "belt-balancer",
        enabled = true,
        energy_required = 1,
        ingredients = {
            { "electronic-circuit", 5 },
            { "iron-plate", 5 },
            { "transport-belt", 4 }
        },
        result = "belt-balancer"
    }
}