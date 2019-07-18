function math.gcd(a, b) -- great common divisor (euclidean algorithm)
    while b ~= 0 do
        a, b = b, a % b
    end
    return a
end
