---get_next_balancer_unit_number
---get the next balancer unit_number to use. Also set the unit_number tracker one up.
---@return uint the unit_number to use
function get_next_balancer_unit_number()
    local cur_value = global.next_balancer_unit_number
    global.next_balancer_unit_number = global.next_balancer_unit_number + 1
    return cur_value
end

---get_next_lane_unit_number
---get the next lane unit_number to use. Also set the unit_number tracker one up.
---@return uint the unit_number to use
function get_next_lane_unit_number()
    local cur_value = global.next_lane_unit_number
    global.next_lane_unit_number = global.next_lane_unit_number + 1
    return cur_value
end
