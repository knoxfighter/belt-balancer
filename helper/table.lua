function remove_from_table(_table, remove_value)
    for key, value in pairs(_table) do
        if value == remove_value then
            table.remove(_table, key)
            return true
        end
    end
end

function table.contains(table, element)
    for _, table_element in pairs(table) do
        if table_element == element then
            return true
        end
    end
    return false
end
