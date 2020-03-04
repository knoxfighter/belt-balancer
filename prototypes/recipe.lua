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
            { "balancer-part", 2 }
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
            { "advanced-circuit", 15 },
            { "express-transport-belt", 5 },
        },
        results = {
            { "balancer-part", 3 }
        },
        order = "d[balancer]-c[balancer]"
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
                order = "d[balancer]-0a[balancer]"
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
            order = "d[balancer]-d[balancer]"
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
            order = "d[balancer]-e[balancer]"
        },
    }
end

-- Update recipes for IR-Integration!
-- Iron is not available in early stages, so recipes are basedon early game items
-- Pistons are imho a very good ingredient
if mods["IndustrialRevolution"] then
    data.raw.recipe["belt-balancer-normal-belt"].ingredients = {
        { "transport-belt", 10 },
        { "tin-plate", 15 },
        { "copper-piston", 10 },
    }
    data.raw.recipe["belt-balancer-fast-belt"].ingredients = {
        { "fast-transport-belt", 10 },
        { "iron-plate", 15 },
        { "iron-piston", 10 },
    }
    data.raw.recipe["belt-balancer-express-belt"].ingredients = {
        { "express-transport-belt", 10 },
        { "steel-plate", 15 },
        { "steel-piston", 10 },
    }
end
