data:extend {
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
        result = "balancer-part",
        order = "g[balancer]-a[balancer]"
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
            { "balancer-part", 2 }
        },
        order = "g[balancer]-b[balancer]"
    },
    {
        type = "recipe",
        name = "belt-balancer-express-belt",
        enabled = false,
        energy_required = 2,
        ingredients = {
            { "iron-gear-wheel", 20 },
            { "advanced-circuit", 15 },
            { "express-transport-belt", 5 },
        },
        results = {
            { "balancer-part", 3 }
        },
        order = "g[balancer]-c[balancer]"
    },
}

if mods["boblogistics"] then
    -- add recipes for the additional boblogistics belts
    if settings.startup["bobmods-logistics-beltoverhaul"].value == true then
        data:extend {
            {
                type = "recipe",
                name = "belt-balancer-basic-belt",
                enabled = false,
                energy_required = 5,
                ingredients = {
                    { "iron-gear-wheel", 25 },
                    { "electronic-circuit", 20 },
                    { "basic-transport-belt", 10 },
                },
                result = "balancer-part",
                order = "g[balancer]-0a[balancer]"
            },
        }
    end

    data:extend {
        {
            type = "recipe",
            name = "belt-balancer-turbo-belt",
            enabled = false,
            energy_required = 1.8,
            ingredients = {
                { "iron-gear-wheel", 20 },
                { "processing-unit", 3 },
                { "turbo-transport-belt", 10 },
            },
            results = {
                { "balancer-part", 4 }
            },
            order = "g[balancer]-d[balancer]"
        },
        {
            type = "recipe",
            name = "belt-balancer-ultimate-belt",
            enabled = false,
            energy_required = 1.5,
            ingredients = {
                { "iron-gear-wheel", 20 },
                { "processing-unit", 5 },
                { "ultimate-transport-belt", 10 },
            },
            results = {
                { "balancer-part", 5 }
            },
            order = "g[balancer]-e[balancer]"
        },
    }
end

-- NOTICE IndustrialRevolution is not developed anymore and it will not be updated to 0.18 :(
