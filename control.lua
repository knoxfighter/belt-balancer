-- print(serpent.block())

--local util = require("util")


script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity},
    function(e)

    end
)

script.on_event({defines.events.on_entity_died, defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity},
    function(e)

    end
)

script.on_event("open-train-stop-overview",
    function(e)

    end
)

script.on_event(defines.events.on_gui_closed,
    function(e)
    end
)

script.on_event(defines.events.on_gui_click,
    function(e)

    end
)

script.on_event(defines.events.on_gui_text_changed,
    function(e)

    end
)

script.on_event(defines.events.on_player_display_resolution_changed,
    function(e)
    end
)

script.on_event(defines.events.on_entity_renamed,
    function(e)

    end
)
-- on new setup and when mod changes, all stops will be added new
script.on_init()

-- If some mod is changed, so train-stops are not valid anymore ... also reload
script.on_configuration_changed()
