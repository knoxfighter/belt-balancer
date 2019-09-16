require("helper.technology_calc")

---set_bobs_logistic_group
---@param type string
---@param recipe_name string recipe to change group
---@param tier number tier group to change subgroup
function set_bobs_logistic_group(type, recipe_name, tier)
    local recipe = data.raw[type][recipe_name]
    recipe.group = "bob-logistics"
    recipe.subgroup = "bob-logistic-tier-" .. tier
end

if mods["boblogistics"] then
    -- recalculate technology costs
    -- this is a simple mathToFloor to 10/25 exponent
    -- this has to be done, cause boblogistics is updating the costs in data-updates too.
    if settings.startup["bobmods-logistics-beltoverhaul"].value == true then
        data.raw.technology["belt-balancer-0"].unit.count = data.raw.technology["logistics-0"].unit.count
    end
    data.raw.technology["belt-balancer-1"].unit.count = data.raw.technology["logistics"].unit.count
    data.raw.technology["belt-balancer-2"].unit.count = technology.calc_cost_round(data.raw.technology["logistics-2"].unit.count, 10)
    data.raw.technology["belt-balancer-3"].unit.count = technology.calc_cost_round(data.raw.technology["logistics-3"].unit.count, 25)
    data.raw.technology["belt-balancer-4"].unit.count = technology.calc_cost_round(data.raw.technology["logistics-4"].unit.count, 25)
    data.raw.technology["belt-balancer-5"].unit.count = technology.calc_cost_round(data.raw.technology["logistics-5"].unit.count, 25)

    -- move recipes to boblogistics item group
    if settings.startup["bobmods-logistics-beltoverhaul"].value == true then
        set_bobs_logistic_group("recipe", "belt-balancer-basic-belt", 0)
    end
    set_bobs_logistic_group("recipe", "belt-balancer-normal-belt", 1)
    set_bobs_logistic_group("recipe", "belt-balancer-fast-belt", 2)
    set_bobs_logistic_group("recipe", "belt-balancer-express-belt", 3)
    set_bobs_logistic_group("recipe", "belt-balancer-turbo-belt", 4)
    set_bobs_logistic_group("recipe", "belt-balancer-ultimate-belt", 5)

    set_bobs_logistic_group("item", "belt-balancer", 5)

    if data.raw.item["advanced-processing-unit"] then
        for k, v in pairs(data.raw.recipe["belt-balancer-ultimate-belt"].ingredients) do
            if v[1] == "processing-unit" then
                v[1] = "advanced-processing-unit"
                v[2] = 3
                break
            end
        end
    end
end
