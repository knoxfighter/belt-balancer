function test_mod(player_index)
    local player = game.get_player(player_index)
    local surface = player.surface

    local function clear_area(clear_area)
        local real_area = { { clear_area[1][1] - 1, clear_area[1][2] - 1 }, { clear_area[2][1] + 2, clear_area[2][2] + 2 } }
        local clear_entities = surface.find_entities_filtered {
            area = real_area,
            type = {
                "character",
                "splitter",
                "transport-belt",
                "underground-belt"
            },
            name = {
                "creative-mod_item-source",
                "creative-mod_item-void"
            },
            invert = true
        }
        for _, clear_entity in pairs(clear_entities) do

            if not clear_entity.destroy() then
                clear_entity.die(nil)
            end
        end

        surface.destroy_decoratives { area = real_area }
    end

    ---@param position Position
    local function create_item_source(position)
        surface.create_entity {
            name = "creative-mod_item-source",
            position = position,
            force = player.force,
            filters = { { index = 1, name = "iron-plate" }, { index = 2, name = "iron-ore" } },
            raise_built = true
        }
    end

    ---@param position Position
    local function create_item_void(position)
        local created_item_source = surface.create_entity {
            name = "creative-mod_item-void",
            position = position,
            force = player.force,
            raise_built = true
        }
    end

    ---@overload fun(position:Position)
    ---@param position Position
    ---@param belt_prefix string
    local function create_belt(position, belt_prefix)
        belt_prefix = belt_prefix or ""

        surface.create_entity {
            name = belt_prefix .. "transport-belt",
            position = position,
            direction = defines.direction.south,
            force = player.force,
            raise_built = true
        }
    end

    local function create_underground_belt_input(position, belt_prefix)
        belt_prefix = belt_prefix or ""

        surface.create_entity {
            name = belt_prefix .. "underground-belt",
            position = position,
            direction = defines.direction.south,
            force = player.force,
            raise_built = true,
            type = "input"
        }
    end

    local function create_underground_belt_output(position, belt_prefix)
        belt_prefix = belt_prefix or ""

        surface.create_entity {
            name = belt_prefix .. "underground-belt",
            position = position,
            direction = defines.direction.south,
            force = player.force,
            raise_built = true,
            type = "output"
        }
    end

    ---@overload fun(position:Position)
    ---@param position Position
    ---@param belt_prefix string
    local function create_underground_belt(position, belt_prefix)
        create_underground_belt_input(position, belt_prefix)

        local one_lower_pos = { x = position[1], y = position[2] + 1 }
        create_underground_belt_output(one_lower_pos, belt_prefix)
    end

    ---@overload fun(position:Position)
    ---@param position Position
    ---@param belt_prefix string
    local function create_splitter(position, belt_prefix)
        belt_prefix = belt_prefix or ""

        surface.create_entity {
            name = belt_prefix .. "splitter",
            position = position,
            direction = defines.direction.south,
            force = player.force,
            raise_built = true
        }
    end

    ---@param position Position
    ---@return LuaEntity created entity
    local function create_part(position)
        return surface.create_entity {
            name = "balancer-part",
            position = position,
            direction = defines.direction.south,
            force = player.force,
            raise_built = true
        }
    end

    local function destroy_entity(position)
        local entities = surface.find_entities({ position, { position[1] + 1, position[2] + 1 } })
        for _, entity in pairs(entities) do
            entity.destroy({ raise_destroy = true })
        end
    end

    local function rotate_entity(position)
        -- get entity
        local entities = surface.find_entities({ position, { position[1] + 1, position[2] + 1 } })
        -- rotate entity
        for _, entity in pairs(entities) do
            entity.rotate({ by_player = player })
        end
    end

    ---setup without 3-4-5, there has to be placed the test itself
    ---@param x number
    ---@param base_y number
    ---@param belt_prefix string
    local function create_basic_setup(x, base_y, belt_prefix)
        clear_area({ { x, base_y }, { x, base_y + 8 } })
        create_item_source({ x, base_y })
        create_belt({ x, base_y + 1 }, belt_prefix)
        create_belt({ x, base_y + 2 }, belt_prefix)
        create_belt({ x, base_y + 6 }, belt_prefix)
        create_belt({ x, base_y + 7 }, belt_prefix)
        create_item_void({ x, base_y + 8 })
    end

    ---setup without 3-4-5-6-7, there has to be placed the test itself.
    ---This is extended to allow underground belts to be placed by the test.
    ---@param x number
    ---@param base_y number
    ---@param belt_prefix string
    local function create_extended_setup(x, base_y, belt_prefix)
        clear_area({ { x, base_y }, { x, base_y + 10 } })
        create_item_source({ x, base_y })
        create_belt({ x, base_y + 1 }, belt_prefix)
        create_belt({ x, base_y + 2 }, belt_prefix)
        create_belt({ x, base_y + 8 }, belt_prefix)
        create_belt({ x, base_y + 9 }, belt_prefix)
        create_item_void({ x, base_y + 10 })
    end

    ---@param current_x number
    ---@param base_y number
    ---@param belt_prefix string
    local function check_built(current_x, base_y, belt_prefix)
        -- test 1.1: normals belts ; 1. part, 2. input, 3. output
        create_basic_setup(current_x, base_y, belt_prefix)
        create_part({ current_x, base_y + 4 })
        create_belt({ current_x, base_y + 3 }, belt_prefix)
        create_belt({ current_x, base_y + 5 }, belt_prefix)
        current_x = current_x + 2

        -- test 1.2: normals belts ; 1. part, 2. output, 3. input
        create_basic_setup(current_x, base_y, belt_prefix)
        create_part({ current_x, base_y + 4 })
        create_belt({ current_x, base_y + 5 }, belt_prefix)
        create_belt({ current_x, base_y + 3 }, belt_prefix)
        current_x = current_x + 2

        -- test 1.3: normals belts ; 1. input, 2. output, 3. part
        create_basic_setup(current_x, base_y, belt_prefix)
        create_belt({ current_x, base_y + 3 }, belt_prefix)
        create_belt({ current_x, base_y + 5 }, belt_prefix)
        create_part({ current_x, base_y + 4 })
        current_x = current_x + 5

        -- test 2.1: underground belts ; 1. part, 2. input, 3. output
        create_extended_setup(current_x, base_y, belt_prefix)
        create_part({ current_x, base_y + 5 })
        create_underground_belt({ current_x, base_y + 3 }, belt_prefix)
        create_underground_belt({ current_x, base_y + 6 }, belt_prefix)
        current_x = current_x + 2

        -- test 2.2: underground belts ; 1. part, 2. output, 3. input
        create_extended_setup(current_x, base_y, belt_prefix)
        create_part({ current_x, base_y + 5 })
        create_underground_belt({ current_x, base_y + 6 }, belt_prefix)
        create_underground_belt({ current_x, base_y + 3 }, belt_prefix)
        current_x = current_x + 2

        -- test 2.3: underground belts ; 1. input, 2. output, 3. part
        create_extended_setup(current_x, base_y, belt_prefix)
        create_underground_belt({ current_x, base_y + 3 }, belt_prefix)
        create_underground_belt({ current_x, base_y + 6 }, belt_prefix)
        create_part({ current_x, base_y + 5 })
        current_x = current_x + 5

        -- test 3.1.1: splitter ; 1. part, 2. input, 3. output ; splitter to right
        create_basic_setup(current_x, base_y, belt_prefix)
        create_part({ current_x, base_y + 4 })
        create_splitter({ current_x + 1, base_y + 3 }, belt_prefix)
        create_splitter({ current_x + 1, base_y + 5 }, belt_prefix)
        create_belt({ current_x + 1, base_y + 4 }, belt_prefix)
        current_x = current_x + 3

        -- test 3.1.2: splitter ; 1. part, 2. input, 3. output ; splitter to left
        create_basic_setup(current_x, base_y, belt_prefix)
        create_part({ current_x, base_y + 4 })
        create_splitter({ current_x, base_y + 3 }, belt_prefix)
        create_splitter({ current_x, base_y + 5 }, belt_prefix)
        create_belt({ current_x - 1, base_y + 4 }, belt_prefix)
        current_x = current_x + 3

        -- test 3.2.1: splitter ; 1. part, 2. output, 3. input ; splitter to right
        create_basic_setup(current_x, base_y, belt_prefix)
        create_part({ current_x, base_y + 4 })
        create_splitter({ current_x + 1, base_y + 5 }, belt_prefix)
        create_splitter({ current_x + 1, base_y + 3 }, belt_prefix)
        create_belt({ current_x + 1, base_y + 4 }, belt_prefix)
        current_x = current_x + 3

        -- test 3.2.2: splitter ; 1. part, 2. output, 3. input ; splitter to left
        create_basic_setup(current_x, base_y, belt_prefix)
        create_part({ current_x, base_y + 4 })
        create_splitter({ current_x, base_y + 5 }, belt_prefix)
        create_splitter({ current_x, base_y + 3 }, belt_prefix)
        create_belt({ current_x - 1, base_y + 4 }, belt_prefix)
        current_x = current_x + 3

        -- test 3.3.1: splitter ; 1. input, 2. output, 3. part ; splitter to right
        create_basic_setup(current_x, base_y, belt_prefix)
        create_splitter({ current_x + 1, base_y + 3 }, belt_prefix)
        create_splitter({ current_x + 1, base_y + 5 }, belt_prefix)
        create_part({ current_x, base_y + 4 })
        create_belt({ current_x + 1, base_y + 4 }, belt_prefix)
        current_x = current_x + 3

        -- test 3.3.2: splitter ; 1. input, 2. output, 3. part ; splitter to left
        create_basic_setup(current_x, base_y, belt_prefix)
        create_splitter({ current_x, base_y + 3 }, belt_prefix)
        create_splitter({ current_x, base_y + 5 }, belt_prefix)
        create_part({ current_x, base_y + 4 })
        create_belt({ current_x - 1, base_y + 4 }, belt_prefix)
        current_x = current_x + 3

        return current_x
    end

    local function check_multipart_belts(current_x)
        -- test 1: two parts, two belts ; yellow, red belt ; first parts
        create_basic_setup(current_x, 0, "")
        create_basic_setup(current_x + 1, 0, "fast-")
        create_part({ current_x, 4 })
        create_part({ current_x + 1, 4 })

        create_belt({ current_x, 3 }, "")
        create_belt({ current_x + 1, 3 }, "fast-")

        create_belt({ current_x, 5 }, "")
        create_belt({ current_x + 1, 5 }, "fast-")

        current_x = current_x + 4

        -- test 2: two parts, two belts ; yellow, blue belt ; first parts
        create_basic_setup(current_x, 0, "")
        create_basic_setup(current_x + 1, 0, "express-")
        create_part({ current_x, 4 })
        create_part({ current_x + 1, 4 })

        create_belt({ current_x, 3 }, "")
        create_belt({ current_x + 1, 3 }, "express-")

        create_belt({ current_x, 5 }, "")
        create_belt({ current_x + 1, 5 }, "express-")
        current_x = current_x + 4

        -- test 3: two parts, two belts ; red, blue belt ; first parts
        create_basic_setup(current_x, 0, "fast-")
        create_basic_setup(current_x + 1, 0, "express-")
        create_part({ current_x, 4 })
        create_part({ current_x + 1, 4 })

        create_belt({ current_x, 3 }, "fast-")
        create_belt({ current_x + 1, 3 }, "express-")

        create_belt({ current_x, 5 }, "fast-")
        create_belt({ current_x + 1, 5 }, "express-")

        return current_x + 8
    end

    local function check_part_add(current_x)
        -- test 1: two parts, two belts ; belts first
        create_basic_setup(current_x, 0)
        create_basic_setup(current_x + 1, 0)

        create_belt({ current_x, 3 })
        create_belt({ current_x + 1, 3 })

        create_belt({ current_x, 5 })
        create_belt({ current_x + 1, 5 })

        create_part({ current_x, 4 })
        create_part({ current_x + 1, 4 })
        current_x = current_x + 8

        return current_x
    end

    local function check_part_merge(current_x)
        -- test 1: 3 parts, 3 belts ; belts first, left and right part second, middle part last
        create_basic_setup(current_x, 0)
        create_basic_setup(current_x + 1, 0)
        create_basic_setup(current_x + 2, 0)

        create_belt({ current_x, 3 })
        create_belt({ current_x + 1, 3 })
        create_belt({ current_x + 2, 3 })

        create_part({ current_x, 4 })
        create_part({ current_x + 1, 4 })
        create_part({ current_x + 2, 4 })

        create_belt({ current_x, 5 })
        create_belt({ current_x + 1, 5 })
        create_belt({ current_x + 2, 5 })
        current_x = current_x + 5

        -- test 2: 3 parts, 3 belts, middle part one to bottom, middle part will merge 3 balancer
        create_basic_setup(current_x, 0)
        create_basic_setup(current_x + 1, 0)
        create_basic_setup(current_x + 2, 0)

        create_belt({ current_x, 3 })
        create_belt({ current_x + 1, 3 })
        create_belt({ current_x + 2, 3 })

        create_part({ current_x, 4 })
        create_part({ current_x + 2, 4 })

        create_belt({ current_x, 5 })
        create_part({ current_x + 1, 5 })
        create_belt({ current_x + 2, 5 })

        create_part({ current_x + 1, 4 })

        return current_x + 5
    end

    local function check_balance(current_x, base_y)
        -- test 1: 1 input, 4 output
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)
        create_basic_setup(current_x + 2, base_y)
        create_basic_setup(current_x + 3, base_y)

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })
        create_part({ current_x + 2, base_y + 4 })
        create_part({ current_x + 3, base_y + 4 })

        create_belt({ current_x, base_y + 3 })

        create_belt({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })
        create_belt({ current_x + 2, base_y + 5 })
        create_belt({ current_x + 3, base_y + 5 })
        current_x = current_x + 6

        -- test 2: 4 input, 1 output
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)
        create_basic_setup(current_x + 2, base_y)
        create_basic_setup(current_x + 3, base_y)

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })
        create_part({ current_x + 2, base_y + 4 })
        create_part({ current_x + 3, base_y + 4 })

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })
        create_belt({ current_x + 2, base_y + 3 })
        create_belt({ current_x + 3, base_y + 3 })

        create_belt({ current_x, base_y + 5 })
        current_x = current_x + 10

        return current_x
    end

    local function check_remove_belts(current_x, base_y)
        -- test 1.1: 2 lines, 1. setup, 2. remove input belt
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })

        create_belt({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })

        destroy_entity({ current_x + 1, base_y + 3 })
        current_x = current_x + 4

        -- test 1.2: 2 lines, 1. setup, 2. remove output belt
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })

        create_belt({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })

        destroy_entity({ current_x + 1, base_y + 5 })
        current_x = current_x + 4

        -- test 2.1: 2 underground-lines, 1. setup, 2. remove input belt
        create_extended_setup(current_x, base_y)
        create_extended_setup(current_x + 1, base_y)

        create_underground_belt({ current_x, base_y + 3 })
        create_underground_belt({ current_x + 1, base_y + 3 })

        create_part({ current_x, base_y + 5 })
        create_part({ current_x + 1, base_y + 5 })

        create_underground_belt({ current_x, base_y + 6 })
        create_underground_belt({ current_x + 1, base_y + 6 })

        destroy_entity({ current_x + 1, base_y + 4 })
        current_x = current_x + 4

        -- test 2.2: 2 underground-lines, 1. setup, 2. remove output belt
        create_extended_setup(current_x, base_y)
        create_extended_setup(current_x + 1, base_y)

        create_underground_belt({ current_x, base_y + 3 })
        create_underground_belt({ current_x + 1, base_y + 3 })

        create_part({ current_x, base_y + 5 })
        create_part({ current_x + 1, base_y + 5 })

        create_underground_belt({ current_x, base_y + 6 })
        create_underground_belt({ current_x + 1, base_y + 6 })

        destroy_entity({ current_x + 1, base_y + 6 })
        current_x = current_x + 5

        -- test 3.1: 2 splitter, 1. setup, 2. remove input splitter
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)

        create_splitter({ current_x, base_y + 3 })
        create_splitter({ current_x + 2, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })

        create_splitter({ current_x, base_y + 5 })
        create_splitter({ current_x + 2, base_y + 5 })

        destroy_entity({ current_x + 2, base_y + 3 })
        current_x = current_x + 5

        -- test 3.2: 2 splitter, 1. setup, 2. remove output splitter
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)

        create_splitter({ current_x, base_y + 3 })
        create_splitter({ current_x + 2, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })

        create_splitter({ current_x, base_y + 5 })
        create_splitter({ current_x + 2, base_y + 5 })

        destroy_entity({ current_x + 2, base_y + 5 })
        current_x = current_x + 5
    end

    local function check_remove_part(current_x, base_y)
        -- test 1: 1 belt, 1. setup, 2. remove part
        create_basic_setup(current_x, base_y)
        create_belt({ current_x, base_y + 3 })
        create_part({ current_x, base_y + 4 })
        create_belt({ current_x, base_y + 5 })
        destroy_entity({ current_x, base_y + 4 })
        current_x = current_x + 3

        -- test 2: 2 belts, 1. setup 2. remove one part
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })

        create_belt({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })

        destroy_entity({ current_x + 1, base_y + 4 })
        current_x = current_x + 4

        -- test 3: 2 belts, 1. setup, 2. remove both parts
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })

        create_belt({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })

        destroy_entity({ current_x, base_y + 4 })
        destroy_entity({ current_x + 1, base_y + 4 })
        current_x = current_x + 4

        -- test 4: 3 belts, 1. setup, 2. remove middle part
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)
        create_basic_setup(current_x + 2, base_y)

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })
        create_belt({ current_x + 2, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })
        create_part({ current_x + 2, base_y + 4 })

        create_belt({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })
        create_belt({ current_x + 2, base_y + 5 })

        destroy_entity({ current_x + 1, base_y + 4 })
        current_x = current_x + 5

        -- test 5: 3 belts, 1. setup, 2. remove one upper input belt, 3. remove middle part
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)
        create_basic_setup(current_x + 2, base_y)

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })
        create_belt({ current_x + 2, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })
        create_part({ current_x + 2, base_y + 4 })

        create_belt({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })
        create_belt({ current_x + 2, base_y + 5 })

        destroy_entity({ current_x, base_y + 2 })
        destroy_entity({ current_x + 1, base_y + 4 })
        current_x = current_x + 5

        -- test 5: 3 belts, 1. setup, 2. remove one lower output belt, 3. remove middle part
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)
        create_basic_setup(current_x + 2, base_y)

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })
        create_belt({ current_x + 2, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })
        create_part({ current_x + 2, base_y + 4 })

        create_belt({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })
        create_belt({ current_x + 2, base_y + 5 })

        destroy_entity({ current_x + 2, base_y + 6 })
        destroy_entity({ current_x + 1, base_y + 4 })
        current_x = current_x + 5
    end

    local function check_rotation(current_x, base_y)
        -- test 1.1: 1 belt, 1. setup, 2. rotate input
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })

        create_belt({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })

        rotate_entity({ current_x, base_y + 3 })
        current_x = current_x + 4

        -- test 1.2: 1 belt, 1. setup, 2. rotate output
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })

        create_belt({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })

        rotate_entity({ current_x, base_y + 5 })
        current_x = current_x + 5

        -- test 2.1: 1 underground, 1. setup 2. rotate input
        create_extended_setup(current_x, base_y)
        create_extended_setup(current_x + 1, base_y)

        create_underground_belt({ current_x, base_y + 3 })
        create_underground_belt({ current_x + 1, base_y + 3 })

        create_part({ current_x, base_y + 5 })
        create_part({ current_x + 1, base_y + 5 })

        create_underground_belt({ current_x, base_y + 6 })
        create_underground_belt({ current_x + 1, base_y + 6 })

        rotate_entity({ current_x, base_y + 4 })
        current_x = current_x + 4

        -- test 2.2: 1 underground, 1. setup 2. rotate output
        create_extended_setup(current_x, base_y)
        create_extended_setup(current_x + 1, base_y)

        create_underground_belt({ current_x, base_y + 3 })
        create_underground_belt({ current_x + 1, base_y + 3 })

        create_part({ current_x, base_y + 5 })
        create_part({ current_x + 1, base_y + 5 })

        create_underground_belt({ current_x, base_y + 6 })
        create_underground_belt({ current_x + 1, base_y + 6 })

        rotate_entity({ current_x, base_y + 6 })
        current_x = current_x + 5

        -- test 3.1: 1 splitter, 1. setup, 2. rotate input
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)

        create_splitter({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })

        create_belt({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })

        rotate_entity({ current_x, base_y + 3 })
        current_x = current_x + 4

        -- test 3.2: 1 splitter, 1. setup, 2. rotate input
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })

        create_splitter({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })

        rotate_entity({ current_x, base_y + 5 })
        current_x = current_x + 5

        return current_x
    end

    local function check_buffer(current_x, base_y)
        -- test 1: remove balancer ; 1. setup, 2. fill buffer, 3. remove part
        create_belt({ current_x, base_y })
        local part_entity = create_part({ current_x, base_y + 1 })
        create_belt({ current_x, base_y + 2 })

        -- fill buffer with stuff
        local part = part_functions.get_or_create(part_entity)
        local balancer_index = balancer_functions.find_from_part(part)
        local balancer = global.balancer[balancer_index]
        table.insert(balancer.buffer, { name = "iron-plate" })
        table.insert(balancer.buffer, { name = "iron-plate" })
        table.insert(balancer.buffer, { name = "iron-plate" })

        destroy_entity({ current_x, base_y + 1 })

        current_x = current_x + 5

        -- test 2: 3 parts, split balancer ; 1. setup, 2. fill buffer, 3. remove middle part
        create_belt({ current_x, base_y })
        create_belt({ current_x + 1, base_y })
        create_belt({ current_x + 2, base_y })

        create_part({ current_x, base_y + 1 })
        create_part({ current_x + 1, base_y + 1 })
        local part_entity = create_part({ current_x + 2, base_y + 1 })

        create_belt({ current_x, base_y + 2 })
        create_belt({ current_x + 1, base_y + 2 })
        create_belt({ current_x + 2, base_y + 2 })

        -- fill buffer with stuff
        local part = part_functions.get_or_create(part_entity)
        local balancer_index = balancer_functions.find_from_part(part)
        local balancer = global.balancer[balancer_index]
        table.insert(balancer.buffer, { name = "iron-plate" })
        table.insert(balancer.buffer, { name = "iron-plate" })
        table.insert(balancer.buffer, { name = "iron-plate" })

        destroy_entity({ current_x + 1, base_y + 1 })

        return current_x + 6
    end

    local function check_basic_usage(current_x, base_y)
        -- test 1.1: 1 lane ; 1. setup, 2. remove output, 3. add output
        create_basic_setup(current_x, base_y)
        create_belt({ current_x, base_y + 3 })
        create_part({ current_x, base_y + 4 })
        create_belt({ current_x, base_y + 5 })
        destroy_entity({ current_x, base_y + 5 })
        create_belt({ current_x, base_y + 5 })
        current_x = current_x + 2

        -- test 1.2: 1 lane ; 1. setup, 2. remove input, 3. add input
        create_basic_setup(current_x, base_y)
        create_belt({ current_x, base_y + 3 })
        create_part({ current_x, base_y + 4 })
        create_belt({ current_x, base_y + 5 })
        destroy_entity({ current_x, base_y + 3 })
        create_belt({ current_x, base_y + 3 })
        current_x = current_x + 2

        -- test 1.3: 1 lane ; 1. setup, 2. remove input/output, 3. add input/output
        create_basic_setup(current_x, base_y)
        create_belt({ current_x, base_y + 3 })
        create_part({ current_x, base_y + 4 })
        create_belt({ current_x, base_y + 5 })
        destroy_entity({ current_x, base_y + 3 })
        destroy_entity({ current_x, base_y + 5 })
        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x, base_y + 5 })
        current_x = current_x + 4

        -- test 2.1: 2 lanes ; 1. setup, 2. remove one input, 3. add input
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })

        create_belt({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })

        destroy_entity({ current_x + 1, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })
        current_x = current_x + 3

        -- test 2.2: 2 lanes ; 1. setup, 2. remove one output, 3. add output
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })

        create_belt({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })

        destroy_entity({ current_x + 1, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })
        current_x = current_x + 3

        -- test 2.3: 2 lanes ; 1. setup, 2. remove one input/output, 3. add input/output
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })

        create_belt({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })

        destroy_entity({ current_x + 1, base_y + 3 })
        destroy_entity({ current_x + 1, base_y + 5 })
        create_belt({ current_x + 1, base_y + 3 })
        create_belt({ current_x + 1, base_y + 5 })
        current_x = current_x + 3

        -- test 2.4: 2 lanes ; 1. setup, 2. remove one part, 3. add part
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })

        create_belt({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })

        destroy_entity({ current_x + 1, base_y + 4 })
        --create_part({ current_x + 1, base_y + 4 })
        current_x = current_x + 5

        -- test 3.1: 3 lanes ; 1. setup, 2. remove middle, 3. remove input belt, 4. add middle, 5. add belt
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)
        create_basic_setup(current_x + 2, base_y)

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })
        create_belt({ current_x + 2, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })
        create_part({ current_x + 2, base_y + 4 })

        create_belt({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })
        create_belt({ current_x + 2, base_y + 5 })

        destroy_entity({ current_x + 1, base_y + 4 })
        destroy_entity({ current_x + 2, base_y + 3 })

        create_part({ current_x + 1, base_y + 4 })
        create_belt({ current_x + 2, base_y + 3 })
        current_x = current_x + 5
    end

    local function check_underground_skip(current_x, base_y)
        -- test 1: 1 underground, test if input is connected
        create_extended_setup(current_x, base_y)
        create_extended_setup(current_x + 1, base_y)

        create_belt({ current_x, base_y + 3 })

        create_underground_belt_input({ current_x, base_y + 4 })
        create_belt({ current_x + 1, base_y + 4 })

        create_part({ current_x, base_y + 5 })
        create_part({ current_x + 1, base_y + 5 })

        create_belt({ current_x + 1, base_y + 6 })

        create_underground_belt_output({ current_x, base_y + 7 })
        create_belt({ current_x + 1, base_y + 7 })
        current_x = current_x + 4

        -- test 2: 1 underground, test if output is connected
        create_extended_setup(current_x, base_y)
        create_extended_setup(current_x + 1, base_y)

        --create_underground_belt_input({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })

        create_belt({ current_x + 1, base_y + 4 })

        create_part({ current_x, base_y + 5 })
        create_part({ current_x + 1, base_y + 5 })

        create_underground_belt_output({ current_x, base_y + 6 })
        create_belt({ current_x + 1, base_y + 6 })

        create_belt({ current_x, base_y + 7 })
        create_belt({ current_x + 1, base_y + 7 })
        current_x = current_x + 4

        return current_x + 2
    end

    local function check_different_input_output_speed(current_x, base_y)
        -- test 1: 4 belts, 3 yellow input, 1 red output
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)
        create_basic_setup(current_x + 2, base_y)
        create_basic_setup(current_x + 3, base_y, "fast-")

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })
        create_belt({ current_x + 2, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })
        create_part({ current_x + 2, base_y + 4 })
        create_part({ current_x + 3, base_y + 4 })

        create_belt({ current_x + 3, base_y + 5 }, "fast-")
        current_x = current_x + 6

        -- test 2: 4 belts, 3 blue input, 1 red output
        create_basic_setup(current_x, base_y, "express-")
        create_basic_setup(current_x + 1, base_y, "express-")
        create_basic_setup(current_x + 2, base_y, "express-")
        create_basic_setup(current_x + 3, base_y, "fast-")

        create_belt({ current_x, base_y + 3 }, "express-")
        create_belt({ current_x + 1, base_y + 3 }, "express-")
        create_belt({ current_x + 2, base_y + 3 }, "express-")

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })
        create_part({ current_x + 2, base_y + 4 })
        create_part({ current_x + 3, base_y + 4 })

        create_belt({ current_x + 3, base_y + 5 }, "fast-")
        current_x = current_x + 6

        -- test 3: 4 belts, 3 yellow input, 1 blue output
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)
        create_basic_setup(current_x + 2, base_y)
        create_basic_setup(current_x + 3, base_y, "express-")

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })
        create_belt({ current_x + 2, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })
        create_part({ current_x + 2, base_y + 4 })
        create_part({ current_x + 3, base_y + 4 })

        create_belt({ current_x + 3, base_y + 5 }, "express-")
        current_x = current_x + 6

        -- test 4: 4 belts, 3 red input, 1 blue output
        create_basic_setup(current_x, base_y, "fast-")
        create_basic_setup(current_x + 1, base_y, "fast-")
        create_basic_setup(current_x + 2, base_y, "fast-")
        create_basic_setup(current_x + 3, base_y, "express-")

        create_belt({ current_x, base_y + 3 }, "fast-")
        create_belt({ current_x + 1, base_y + 3 }, "fast-")
        create_belt({ current_x + 2, base_y + 3 }, "fast-")

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })
        create_part({ current_x + 2, base_y + 4 })
        create_part({ current_x + 3, base_y + 4 })

        create_belt({ current_x + 3, base_y + 5 }, "express-")
        current_x = current_x + 6

        -- test 5: 4 belts, 3 red input, 1 yellow output
        create_basic_setup(current_x, base_y, "fast-")
        create_basic_setup(current_x + 1, base_y, "fast-")
        create_basic_setup(current_x + 2, base_y, "fast-")
        create_basic_setup(current_x + 3, base_y)

        create_belt({ current_x, base_y + 3 }, "fast-")
        create_belt({ current_x + 1, base_y + 3 }, "fast-")
        create_belt({ current_x + 2, base_y + 3 }, "fast-")

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })
        create_part({ current_x + 2, base_y + 4 })
        create_part({ current_x + 3, base_y + 4 })

        create_belt({ current_x + 3, base_y + 5 })
        current_x = current_x + 6

        -- test 6: 4 belts, 3 blue input, 1 yellow output
        create_basic_setup(current_x, base_y, "express-")
        create_basic_setup(current_x + 1, base_y, "express-")
        create_basic_setup(current_x + 2, base_y, "express-")
        create_basic_setup(current_x + 3, base_y)

        create_belt({ current_x, base_y + 3 }, "express-")
        create_belt({ current_x + 1, base_y + 3 }, "express-")
        create_belt({ current_x + 2, base_y + 3 }, "express-")

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })
        create_part({ current_x + 2, base_y + 4 })
        create_part({ current_x + 3, base_y + 4 })

        create_belt({ current_x + 3, base_y + 5 })
        current_x = current_x + 6

        -- test 7: 4 belts, 3 blue input, 1 red output
        create_basic_setup(current_x, base_y, "express-")
        create_basic_setup(current_x + 1, base_y, "express-")
        create_basic_setup(current_x + 2, base_y, "express-")
        create_basic_setup(current_x + 3, base_y, "fast-")

        create_belt({ current_x, base_y + 3 }, "express-")
        create_belt({ current_x + 1, base_y + 3 }, "express-")
        create_belt({ current_x + 2, base_y + 3 }, "express-")

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })
        create_part({ current_x + 2, base_y + 4 })
        create_part({ current_x + 3, base_y + 4 })

        create_belt({ current_x + 3, base_y + 5 }, "fast-")
        current_x = current_x + 6
    end

    local function check_bobs_belts(current_x, base_y)
        -- test 0: 2 belts, 2 green
        create_basic_setup(current_x, base_y, "ultimate-")
        create_basic_setup(current_x + 1, base_y, "ultimate-")

        create_belt({ current_x, base_y + 3 }, "ultimate-")
        create_belt({ current_x + 1, base_y + 3 }, "ultimate-")

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })

        create_belt({ current_x, base_y + 5 }, "ultimate-")
        create_belt({ current_x + 1, base_y + 5 }, "ultimate-")
        current_x = current_x + 4

        -- test 1: 4 belts, 3  yellow, 1 purple
        create_basic_setup(current_x, base_y, "fast-")
        create_basic_setup(current_x + 1, base_y, "fast-")
        create_basic_setup(current_x + 2, base_y, "fast-")
        create_basic_setup(current_x + 3, base_y, "turbo-")

        create_belt({ current_x, base_y + 3 }, "fast-")
        create_belt({ current_x + 1, base_y + 3 }, "fast-")
        create_belt({ current_x + 2, base_y + 3 }, "fast-")

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })
        create_part({ current_x + 2, base_y + 4 })
        create_part({ current_x + 3, base_y + 4 })

        create_belt({ current_x + 3, base_y + 5 }, "turbo-")
        current_x = current_x + 6

        -- test 2: 4 belts, 3 yellow, 1 green
        create_basic_setup(current_x, base_y, "fast-")
        create_basic_setup(current_x + 1, base_y, "fast-")
        create_basic_setup(current_x + 2, base_y, "fast-")
        create_basic_setup(current_x + 3, base_y, "ultimate-")

        create_belt({ current_x, base_y + 3 }, "fast-")
        create_belt({ current_x + 1, base_y + 3 }, "fast-")
        create_belt({ current_x + 2, base_y + 3 }, "fast-")

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })
        create_part({ current_x + 2, base_y + 4 })
        create_part({ current_x + 3, base_y + 4 })

        create_belt({ current_x + 3, base_y + 5 }, "ultimate-")
        current_x = current_x + 6

        -- test 3: 4 belts, 1 green, 3 yellow
        create_basic_setup(current_x, base_y, "ultimate-")
        create_basic_setup(current_x + 1, base_y)
        create_basic_setup(current_x + 2, base_y)
        create_basic_setup(current_x + 3, base_y)

        create_belt({ current_x, base_y + 3 }, "ultimate-")

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })
        create_part({ current_x + 2, base_y + 4 })
        create_part({ current_x + 3, base_y + 4 })

        create_belt({ current_x + 1, base_y + 5 })
        create_belt({ current_x + 2, base_y + 5 })
        create_belt({ current_x + 3, base_y + 5 })
        current_x = current_x + 6

        -- test 4: 4 belts, 3 grey, 1 yellow
        create_basic_setup(current_x, base_y, "basic-")
        create_basic_setup(current_x + 1, base_y, "basic-")
        create_basic_setup(current_x + 2, base_y, "basic-")
        create_basic_setup(current_x + 3, base_y)

        create_belt({ current_x, base_y + 3 }, "basic-")
        create_belt({ current_x + 1, base_y + 3 }, "basic-")
        create_belt({ current_x + 2, base_y + 3 }, "basic-")

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })
        create_part({ current_x + 2, base_y + 4 })
        create_part({ current_x + 3, base_y + 4 })

        create_belt({ current_x + 3, base_y + 5 })
        current_x = current_x + 6

        return current_x
    end

    local function check_complete_removal(current_x, base_y)
        -- test 1: 2 belts, remove all parts
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)

        create_belt({ current_x, base_y + 3 })
        create_belt({ current_x + 1, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })

        create_belt({ current_x, base_y + 5 })
        create_belt({ current_x + 1, base_y + 5 })

        destroy_entity({ current_x, base_y + 4 })
        destroy_entity({ current_x + 1, base_y + 4 })
        current_x = current_x + 5

        -- test 2: 2 underground, remove all parts
        create_extended_setup(current_x, base_y)
        create_extended_setup(current_x + 1, base_y)

        create_underground_belt({ current_x, base_y + 3 })
        create_underground_belt({ current_x + 1, base_y + 3 })

        create_part({ current_x, base_y + 5 })
        create_part({ current_x + 1, base_y + 5 })

        create_underground_belt({ current_x, base_y + 6 })
        create_underground_belt({ current_x + 1, base_y + 6 })

        destroy_entity({ current_x, base_y + 5 })
        destroy_entity({ current_x + 1, base_y + 5 })
        current_x = current_x + 5

        -- test 3: 1 splitter, remove all parts
        create_basic_setup(current_x, base_y)
        create_basic_setup(current_x + 1, base_y)

        create_splitter({ current_x + 1, base_y + 3 })

        create_part({ current_x, base_y + 4 })
        create_part({ current_x + 1, base_y + 4 })

        create_splitter({ current_x + 1, base_y + 5 })

        destroy_entity({ current_x, base_y + 4 })
        destroy_entity({ current_x + 1, base_y + 4 })
        current_x = current_x + 8
    end

    local current_x = 0
    local base_y = 0
    local new_current_x = check_built(current_x, base_y)

    base_y = base_y + 15
    check_built(current_x, base_y, "fast-")

    base_y = base_y + 15
    check_built(current_x, base_y, "express-")

    current_x = new_current_x + 6
    base_y = 0
    new_current_x = check_multipart_belts(current_x)

    new_current_x = check_part_add(new_current_x)

    new_current_x = check_part_merge(new_current_x)

    base_y = 15
    check_balance(current_x, base_y)

    base_y = base_y + 15
    check_remove_belts(current_x, base_y)

    base_y = base_y + 15
    check_remove_part(current_x, base_y)

    current_x = new_current_x + 4
    base_y = 0
    new_current_x = check_rotation(current_x, base_y)

    base_y = base_y + 15
    check_buffer(current_x, base_y)

    base_y = base_y + 15
    check_basic_usage(current_x, base_y)

    base_y = base_y + 15
    local cont_current_x = check_underground_skip(current_x, base_y)

    check_different_input_output_speed(cont_current_x or current_x, base_y)

    current_x = new_current_x
    base_y = 0
    check_complete_removal(current_x, base_y)

    base_y = base_y + 15
    if script.active_mods["boblogistics"] then
        check_bobs_belts(current_x, base_y)
    end
end

function test_mod_logic(player_index)
    local player = game.get_player(player_index)
    local surface = player.surface

    local function clear_area(clear_area)
        local real_area = { { clear_area[1][1] - 1, clear_area[1][2] - 1 }, { clear_area[2][1] + 2, clear_area[2][2] + 2 } }
        local clear_entities = surface.find_entities_filtered {
            area = real_area,
            type = {
                "character",
                "splitter",
                "transport-belt",
                "underground-belt"
            },
            name = {
                "creative-mod_item-source",
                "creative-mod_item-void"
            },
            invert = true
        }
        for _, clear_entity in pairs(clear_entities) do

            if not clear_entity.destroy() then
                clear_entity.die(nil)
            end
        end

        surface.destroy_decoratives { area = real_area }
    end

    ---@param position Position
    local function create_item_source(position)
        surface.create_entity {
            name = "creative-mod_item-source",
            position = position,
            force = player.force,
            filters = { { index = 1, name = "iron-plate" }, { index = 2, name = "iron-ore" } },
            raise_built = true
        }
    end

    ---@param position Position
    local function create_item_void(position)
        local created_item_source = surface.create_entity {
            name = "creative-mod_item-void",
            position = position,
            force = player.force,
            raise_built = true
        }
    end

    ---@overload fun(position:Position)
    ---@param position Position
    ---@param belt_prefix string
    local function create_belt(position, belt_prefix)
        belt_prefix = belt_prefix or ""

        surface.create_entity {
            name = belt_prefix .. "transport-belt",
            position = position,
            direction = defines.direction.south,
            force = player.force,
            raise_built = true
        }
    end

    local function create_underground_belt_input(position, belt_prefix)
        belt_prefix = belt_prefix or ""

        surface.create_entity {
            name = belt_prefix .. "underground-belt",
            position = position,
            direction = defines.direction.south,
            force = player.force,
            raise_built = true,
            type = "input"
        }
    end

    local function create_underground_belt_output(position, belt_prefix)
        belt_prefix = belt_prefix or ""

        surface.create_entity {
            name = belt_prefix .. "underground-belt",
            position = position,
            direction = defines.direction.south,
            force = player.force,
            raise_built = true,
            type = "output"
        }
    end

    ---@overload fun(position:Position)
    ---@param position Position
    ---@param belt_prefix string
    local function create_underground_belt(position, belt_prefix)
        create_underground_belt_input(position, belt_prefix)

        local one_lower_pos = { x = position[1], y = position[2] + 1 }
        create_underground_belt_output(one_lower_pos, belt_prefix)
    end

    ---@overload fun(position:Position)
    ---@param position Position
    ---@param belt_prefix string
    local function create_splitter(position, belt_prefix)
        belt_prefix = belt_prefix or ""

        surface.create_entity {
            name = belt_prefix .. "splitter",
            position = position,
            direction = defines.direction.south,
            force = player.force,
            raise_built = true
        }
    end

    ---@param position Position
    ---@return LuaEntity created entity
    local function create_part(position)
        return surface.create_entity {
            name = "balancer-part",
            position = position,
            direction = defines.direction.south,
            force = player.force,
            raise_built = true
        }
    end

    local function destroy_entity(position)
        local entities = surface.find_entities({ position, { position[1] + 1, position[2] + 1 } })
        for _, entity in pairs(entities) do
            entity.destroy({ raise_destroy = true })
        end
    end

    ---setup wih part, but without 3--5
    ---@param x number
    ---@param base_y number
    ---@param belt_prefix string
    local function create_setup(x, base_y, belt_prefix)
        clear_area({ { x, base_y }, { x, base_y + 8 } })
        create_item_source({ x, base_y })
        create_belt({ x, base_y + 1 }, belt_prefix)
        create_belt({ x, base_y + 2 }, belt_prefix)
        create_belt({ x, base_y + 6 }, belt_prefix)
        create_belt({ x, base_y + 7 }, belt_prefix)
        create_item_void({ x, base_y + 8 })
    end

    ---setup wih part, but without 3-4--6-7
    ---@param x number
    ---@param base_y number
    ---@param belt_prefix string
    local function create_extended_setup(x, base_y, belt_prefix)
        clear_area({ { x, base_y }, { x, base_y + 11 } })
        create_item_source({ x, base_y })
        create_belt({ x, base_y + 1 }, belt_prefix)
        create_belt({ x, base_y + 2 }, belt_prefix)
        create_belt({ x, base_y + 8 }, belt_prefix)
        create_belt({ x, base_y + 9 }, belt_prefix)
        create_item_void({ x, base_y + 10 })
    end

    ---@return boolean true if everything is clear!
    local function is_clear()
        return table_size(global.balancer) == 0 and table_size(global.parts)
            and table_size(global.belts) and table_size(global.lanes)
    end

    local function print_all()
        print("Balancer:")
        print(serpent.block(global.balancer))
        print("Parts:")
        print(serpent.block(global.parts))
        print("Belts:")
        print(serpent.block(global.belts))
        print("Lanes:")
        print(serpent.block(global.lanes))
    end

    local current_x = 0
    local base_y = 0

    -- test 1.1: 1 belt
    print("test 1.1")
    create_setup(current_x, base_y)
    create_belt({ current_x, base_y + 3 })
    create_part({ current_x, base_y + 4 })
    create_belt({ current_x, base_y + 5 })
    destroy_entity({ current_x, base_y + 4 })
    current_x = current_x + 2

    if not is_clear() then
        print("!!Error in test 1.1!!")
        print_all()
        return
    end

    -- test 1.2: 1
    print("test 1.2")
    create_extended_setup(current_x, base_y)
    create_underground_belt({ current_x, base_y + 3 })
    create_part({ current_x, base_y + 5 })
    create_underground_belt({ current_x, base_y + 6 })
    destroy_entity({ current_x, base_y + 5 })
    current_x = current_x + 2

    if not is_clear() then
        print("!!Error in test 1.2!!")
        print_all()
        return
    end

    -- test 1.3: 1 splitter
    print("test 1.3")
    current_x = current_x + 1
    create_setup(current_x, base_y)
    create_splitter({ current_x, base_y + 3 })
    create_part({ current_x, base_y + 4 })
    create_splitter({ current_x, base_y + 5 })
    destroy_entity({ current_x, base_y + 4 })
    current_x = current_x + 4

    if not is_clear() then
        print("!!Error in test 1.3!!")
        print_all()
        return
    end

    -- test 2.1: 2 belts
    print("test 2.1")
    create_setup(current_x, base_y)
    create_setup(current_x + 1, base_y)

    create_belt({ current_x, base_y + 3 })
    create_belt({ current_x + 1, base_y + 3 })

    create_part({ current_x, base_y + 4 })
    create_part({ current_x + 1, base_y + 4 })

    create_belt({ current_x, base_y + 5 })
    create_belt({ current_x + 1, base_y + 5 })

    destroy_entity({ current_x, base_y + 4 })
    destroy_entity({ current_x + 1, base_y + 4 })
    current_x = current_x + 4

    if not is_clear() then
        print("!!Error in test 2.1!!")
        print_all()
        return
    end

    -- test 2.2: 2 underground
    print("test 2.2")
    create_extended_setup(current_x, base_y)
    create_extended_setup(current_x + 1, base_y)

    create_underground_belt({ current_x, base_y + 3 })
    create_underground_belt({ current_x + 1, base_y + 3 })

    create_part({ current_x, base_y + 5 })
    create_part({ current_x + 1, base_y + 5 })

    create_underground_belt({ current_x, base_y + 6 })
    create_underground_belt({ current_x + 1, base_y + 6 })

    destroy_entity({ current_x, base_y + 5 })
    destroy_entity({ current_x + 1, base_y + 5 })
    current_x = current_x + 4

    if not is_clear() then
        print("!!Error in test 2.2!!")
        print_all()
        return
    end

    -- test 2.3: 1 splitter (2 parts)
    print("test 2.3")
    create_setup(current_x, base_y)
    create_setup(current_x + 1, base_y)

    create_splitter({ current_x + 1, base_y + 3 })

    create_part({ current_x, base_y + 4 })
    create_part({ current_x + 1, base_y + 4 })

    create_splitter({ current_x + 1, base_y + 5 })

    destroy_entity({ current_x, base_y + 4 })
    destroy_entity({ current_x + 1, base_y + 4 })
    current_x = current_x + 5

    if not is_clear() then
        print("!!Error in test 2.3!!")
        print_all()
        return
    end

    -- test 3.1: 3 belts (remove middle first)
    print("test 3.1")
    create_setup(current_x, base_y)
    create_setup(current_x + 1, base_y)
    create_setup(current_x + 2, base_y)

    create_belt({ current_x, base_y + 3 })
    create_belt({ current_x + 1, base_y + 3 })
    create_belt({ current_x + 2, base_y + 3 })

    create_part({ current_x, base_y + 4 })
    create_part({ current_x + 1, base_y + 4 })
    create_part({ current_x + 2, base_y + 4 })

    create_belt({ current_x, base_y + 5 })
    create_belt({ current_x + 1, base_y + 5 })
    create_belt({ current_x + 2, base_y + 5 })

    destroy_entity({ current_x + 1, base_y + 4 })
    destroy_entity({ current_x, base_y + 4 })
    destroy_entity({ current_x + 2, base_y + 4 })
    current_x = current_x + 5

    if not is_clear() then
        print("!!Error in test 3.1!!")
        print_all()
        return
    end

    -- test 3.2: 3 underground (remove middle first)
    print("test 3.2")
    create_extended_setup(current_x, base_y)
    create_extended_setup(current_x + 1, base_y)
    create_extended_setup(current_x + 2, base_y)

    create_underground_belt({ current_x, base_y + 3 })
    create_underground_belt({ current_x + 1, base_y + 3 })
    create_underground_belt({ current_x + 2, base_y + 3 })

    create_part({ current_x, base_y + 5 })
    create_part({ current_x + 1, base_y + 5 })
    create_part({ current_x + 2, base_y + 5 })

    create_underground_belt({ current_x, base_y + 6 })
    create_underground_belt({ current_x + 1, base_y + 6 })
    create_underground_belt({ current_x + 2, base_y + 6 })

    destroy_entity({ current_x + 1, base_y + 5 })
    destroy_entity({ current_x, base_y + 5 })
    destroy_entity({ current_x + 2, base_y + 5 })
    current_x = current_x + 5

    if not is_clear() then
        print("!!Error in test 3.2!!")
        print_all()
        return
    end

    -- test 3.3: 2 splitter (remove middle first)
    print("test 3.3")
    create_setup(current_x, base_y)
    create_setup(current_x + 1, base_y)
    create_setup(current_x + 2, base_y)

    create_splitter({ current_x + 1, base_y + 3 })
    create_splitter({ current_x + 3, base_y + 3 })

    create_part({ current_x, base_y + 4 })
    create_part({ current_x + 1, base_y + 4 })
    create_part({ current_x + 2, base_y + 4 })

    create_splitter({ current_x + 1, base_y + 5 })
    create_splitter({ current_x + 3, base_y + 5 })

    destroy_entity({ current_x + 1, base_y + 4 })
    destroy_entity({ current_x, base_y + 4 })
    destroy_entity({ current_x + 2, base_y + 4 })
    current_x = current_x + 5

    if not is_clear() then
        print("!!Error in test 3.3!!")
        print_all()
        return
    end
end
