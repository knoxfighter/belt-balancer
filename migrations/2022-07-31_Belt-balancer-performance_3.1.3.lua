global.next_belt_check, _ = next(global.belts, global.next_belt_check)

if global.balancer then
    for _, balancer in pairs(global.balancer) do
	balancer.next_output = next(balancer.output_lanes, balancer.last_success)
    end
end
