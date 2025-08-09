local Grave = Class()

function Grave:init(id, position_table, size, position_px)
    self.id = id
    self.position_table = position_table
    self.size = size
    self.position_px = position_px
    self.dead_locations = {}
end

function Grave:dead_locations_add(sqliteConnection, name, year)
    local dead_location = DeadLocation(self.id, name, year, nil, sqliteConnection)
    table.insert(self.dead_locations, dead_location)
end

function Grave:dead_locations_sort(func)
    table.sort(self.dead_locations, func)
end

function Grave:dead_locations_rm(sqliteConnection,params)
    for i, dead_location in ipairs(self.dead_locations) do
        local match = true
        local rm_query = "DELETE FROM DeadLocation WHERE "
        for key, value in pairs(params) do
            rm_query = rm_query .. key .. " = " .. value .. " AND "
            if dead_location[key] ~= value then
                match = false
                break
            end
        end
        if match then
            sqliteConnection:execute(rm_query)
            table.remove(self.dead_locations, i)
        end
    end
end


return Grave