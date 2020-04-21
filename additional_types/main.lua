---@class Balancer
local Balancer = {}

--- unit_numbers of the related Balancer-Part-Entities. With this, it is possible, to get all parts, from `global.parts`.
---@type uint[]
Balancer.parts = nil

--- unit_number of the lanes, used as INPUT.
---@type uint[]
Balancer.input_lanes = nil

--- unit_number of the lanes, used as OUTPUT.
---@type uint[]
Balancer.output_lanes = nil

--- unit_number of this balancer. The unit_number has to be tracked manually, free unit_number can be get from `global.next_balancer_unit_number`.
---@type uint
Balancer.unit_number = nil

--- The buffer, where items are buffered.
---@type SimpleItemStack[]
Balancer.buffer = nil

--- The tick to run this balancer on
---@type uint
Balancer.nth_tick = nil

--- The last successful output-lane.
---@type uint
Balancer.last_success = nil

--------------------------------------------------------------------------------------------------------------

---@class Belt
local Belt = {}

--- unit_number of related balancer. Related Balancer have to be an INPUT.
--- This is, where the belt is getting its items from
---@type uint[]
Belt.input_balancer = nil

--- unit_number of related balancer. Related Balancer have to be an OUTPUT.
--- This is, where the belt is pushing its items to
---@type uint[]
Belt.output_balancer = nil

--- unit_number to the related lanes
--- Type is: array[index] = unit_number
--- index = transport_line index
---@type table<uint, uint>
Belt.lanes = nil

---@type string|'"underground"'|'"splitter"'|'"belt"'
Belt.type = nil

--- The entity of this belt
---@type LuaEntity
Belt.entity = nil

--- The position of this belt
---@type Position
Belt.position = nil

--- The direction of this belt
---@type defines.direction
Belt.direction = nil
--- The surface, where the belt is on
---@type LuaSurface
Belt.surface = nil

--------------------------------------------------------------------------------------------------------------

---@class Part
local Part = {}

--- Uint to get related balancer
---@type uint
Part.balancer = nil

--- The INPUT belts, that are adjacent to this Part
---@type uint[]
Part.input_belts = nil

--- The OUTPUT belts, that are adjacent to this Part
---@type uint[]
Part.output_belts = nil

--- The INPUT lanes, that are used from the adjacent input belts
---@type uint[]
Part.input_lanes = nil

--- The OUTPUT lanes, that are used from the adjacent input belts
---@type uint[]
Part.output_lanes = nil

--- The entity of this Balancer-Part
---@type LuaEntity
Part.entity = nil

--------------------------------------------------------------------------------------------------------------

---@class Global
local Global = {}

--- Balancer are custom objects, so they have a custom tracked unit_number
---@type table<uint, Balancer>
Global.balancer = nil

--- table of all Balancer-Part-Entities, with additionally information
--- The uint is the unit_number of the related LuaEntity
---@type table<uint, Part>
Global.parts = nil

--- table of all Belts, that are used in Balancer
--- The uint is the unit_number of the related LuaEntity
---@type table<uint, Belt>
Global.belts = nil

--- table of lanes
--- LuaTransportLine has no unit_number. Need to track it myself!!
--- This is here, so it is easier to get the Lines (no need to iterate over all belts and then their lanes)
---@type table<uint, LuaTransportLine>
Global.lanes = nil

--- Balancer need to have a unique id (unit_number). This is, the next free uid to use!
---@type uint
Global.next_balancer_unit_number = nil

--- Lanes need to have a unique id (unit_number). This is the next free uid to use!
---@type uint
Global.next_lane_unit_number = nil

--------------------------------------------------------------------------------------------------------------

---@type Global
global = nil



--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

---@class Find_input_output_belts_result
local Find_input_output_belts_result = {}

---@type LuaEntity
Find_input_output_belts_result.belt = nil

---@type string|'"underground"'|'"splitter"'|'"belt"'
Find_input_output_belts_result.belt_type = nil

---override the use of lanes on this belt. When nil, then use all.
---@type uint[]
Find_input_output_belts_result.lanes = nil

---@class Get_input_output_pos_splitter_result
local Get_input_output_pos_splitter_result = {}

---@type Position
Get_input_output_pos_splitter_result.position = nil

---override the use of lanes on this belt. When nil, then use all.
---@type uint[]
Get_input_output_pos_splitter_result.lanes = nil

---@class Get_input_output_parts_splitter_result : Get_input_output_pos_splitter_result
local Get_input_output_parts_splitter_result = {}

---@type Part
Get_input_output_parts_splitter_result.part = nil


---@class Item_drop_param
local Item_drop_param = {}

---@type LuaInventory
Item_drop_param.buffer = nil

---@type LuaSurface
Item_drop_param.surface = nil

---@type Position
Item_drop_param.position = nil

---@type LuaForce
Item_drop_param.force = nil

