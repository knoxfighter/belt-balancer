function remove_from_table(_table, remove_value)
    for key, value in pairs(_table) do
        if value == remove_value then
            table.remove(_table, key)
            return true
        end
    end
end