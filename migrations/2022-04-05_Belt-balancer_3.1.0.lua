for _, balancer in pairs(global.balancer) do
    for i, _ in pairs(balancer.input_lanes) do
        balancer.input_lanes[i] = global.lanes[i]
    end
    for i, _ in pairs(balancer.output_lanes) do
        balancer.output_lanes[i] = global.lanes[i]
    end
end

for _, part in pairs(global.parts) do
    for i, _ in pairs(part.input_lanes) do
        part.input_lanes[i] = global.lanes[i]
    end
    for i, _ in pairs(part.output_lanes) do
        part.output_lanes[i] = global.lanes[i]
    end
end
