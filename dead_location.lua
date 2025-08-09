local DeadLocation = Class()

function DeadLocation:init(grave_id, name, year, id, sqliteConnection)
    local query, result
    if id then self.id = id
    elseif sqliteConnection then
        result = self.sqliteConnection:execute(query)
        query = string.format(
            "INSERT INTO DeadLocation (name, year, grave_id) VALUES (%s, %d, %d)",
            name, year, grave_id)
        if result then
            self.id = self.sqliteConnection:getlastautoid()
        else
            error("Failed to add dead location.")
        end
    else
        error("Either id or sqliteConnection must be provided.")
    end
    self.grave_id = grave_id
    self.name = name
    self.year = year
end

return DeadLocation