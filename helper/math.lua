function math.gcd(a, b)
    -- great common divisor (euclidean algorithm)
    while b ~= 0 do
        a, b = b, a % b
    end
    return a
end

---floor_mutliple
---round down to a multiple of `multiple`.
---e.g.
---math.floor_multiple(27, 5) = 25
---math.floor_multiple(27, 10) = 20
---@param num number Number to round
---@param multiple number The base of which the result is a multiple of
---@return number The rounded down to multiple
function math.floor_mutliple(num, multiple)
    return multiple * math.floor(num / multiple)
end
