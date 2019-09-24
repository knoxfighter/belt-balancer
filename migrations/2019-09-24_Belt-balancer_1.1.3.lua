require("objects.balancer")

-- balancer_recalculate_nth_tick on every existing balancer
for k, _ in pairs(global.new_balancers) do
    balancer_recalculate_nth_tick(k)
end