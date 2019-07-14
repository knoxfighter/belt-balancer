---convert_LuaItemStack_to_SimpleItemStack
---@param lua_item_stack LuaItemStack
---@return SimpleItemStack
function convert_LuaItemStack_to_SimpleItemStack(lua_item_stack)
    local simple_item =  {
        name = lua_item_stack.name,
        count = lua_item_stack.count,
        health = lua_item_stack.health,
        durability = lua_item_stack.durability,
    }

    if lua_item_stack.prototype.type == "ammo" then
        simple_item.ammo = lua_item_stack.ammo
    end

    if lua_item_stack.prototype.type == "item-with-tags" then
        simple_item.tags = lua_item_stack.tags
    end

    return simple_item
end