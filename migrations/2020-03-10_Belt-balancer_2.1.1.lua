if global.balancer then
    for k, _ in pairs(global.balancer) do
        balancer_functions.recalculate_nth_tick(k)
    end
end
