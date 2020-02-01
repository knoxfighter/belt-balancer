require("helper.technology_calc")

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
            count = data.raw.technology["logistics"].unit.count,
            ingredients = data.raw.technology["logistics"].unit.ingredients,
            time = data.raw.technology["logistics"].unit.time
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
            count = technology.calc_cost_round(data.raw.technology["logistics-2"].unit.count, 10),
            ingredients = data.raw.technology["logistics-2"].unit.ingredients,
            time = data.raw.technology["logistics-2"].unit.time
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
            count = technology.calc_cost_round(data.raw.technology["logistics-3"].unit.count, 25),
            ingredients = data.raw.technology["logistics-3"].unit.ingredients,
            time = data.raw.technology["logistics-3"].unit.time
        },
    }
}

-- add additional technologies for the boblogistics belts
if mods["boblogistics"] then
    if settings.startup["bobmods-logistics-beltoverhaul"].value == true then
        data:extend {
            {
                type = "technology",
                name = "belt-balancer-0",
                icon = "__belt-balancer__/graphics/icons/balancer.png",
                icon_size = 200,
                effects = {
                    {
                        type = "unlock-recipe",
                        recipe = "belt-balancer-basic-belt",
                    }
                },
                prerequisites = { "logistics-0" },
                unit = {
                    count = data.raw.technology["logistics-0"].unit.count,
                    ingredients = data.raw.technology["logistics-0"].unit.ingredients,
                    time = data.raw.technology["logistics-0"].unit.time
                },
            }
        }
        table.insert(data.raw.technology["belt-balancer-1"].prerequisites, "belt-balancer-0")
    end

    data:extend {
        {
            type = "technology",
            name = "belt-balancer-4",
            icon = "__belt-balancer__/graphics/icons/balancer.png",
            icon_size = 200,
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = "belt-balancer-turbo-belt",
                }
            },
            prerequisites = { "logistics-4", "belt-balancer-3" },
            unit = {
                count = technology.calc_cost_round(data.raw.technology["logistics-4"].unit.count, 25),
                ingredients = data.raw.technology["logistics-4"].unit.ingredients,
                time = data.raw.technology["logistics-4"].unit.time
            },
        },
        {
            type = "technology",
            name = "belt-balancer-5",
            icon = "__belt-balancer__/graphics/icons/balancer.png",
            icon_size = 200,
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = "belt-balancer-ultimate-belt",
                }
            },
            prerequisites = { "logistics-5", "belt-balancer-4" },
            unit = {
                count = technology.calc_cost_round(data.raw.technology["logistics-5"].unit.count, 25),
                ingredients = data.raw.technology["logistics-5"].unit.ingredients,
                time = data.raw.technology["logistics-5"].unit.time
            },
        }
    }
end
