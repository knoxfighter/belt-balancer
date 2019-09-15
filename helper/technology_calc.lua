require("helper.math")

technology = {}
---calc_cost_round
---calculate the cost of a technology based on some other technology (number)
---This will be floored to a multiple of `multiple`
---@param base_amount number The base number. You can get them from another technology
---@param multiple number The base of which the result is a multiple of
---@return number The mutliple floored amount
function technology.calc_cost_round(base_amount, multiple)
    -- The number 2/3 is just a value i feel as appropriate.
    return math.floor_mutliple(base_amount / 3 * 2, multiple)
end
