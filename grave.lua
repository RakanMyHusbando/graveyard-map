local Grave = Class()

function Grave:init(sqlite_connection, position_table, size, position_px)
    self.id = nil
    self.sqlite_connection_instance = sqlite_connection
    self.position_table = position_table
    self.size = size
    self.position_px = position_px
    self.id = nil
    local select_result = self:select()
    if select_result == false then
        self.id = self:insert()
        print(self.id)
        if not self.id then return nil end
    end
    self.dead_locations = {}
end

function Grave:select()
    local cursor = self.sqlite_connection_instance:execute(
        "SELECT * FROM grave WHERE row = ? AND column = ?",
        self.position_table[1],
        self.position_table[2]
    )
    local lst = {}
    if cursor then
        local row = cursor:fetch({}, "a")
        while row do
            table.insert(lst, {
                id = row.id,
                position_table = {row.row, row.column},
                size = {row.width, row.height},
                position_px = {row.x, row.y}
            })
            row = cursor:fetch(row, "a")
        end
        if #lst > 1 then
            error("More than one grave found with the same position.")
        elseif #lst == 0 then
            print("Warning: Failed to execute select query.")
            return false
        else
            return true
        end
    end
    return false
end

function Grave:insert()
    local result = self.sqlite_connection_instance:execute(
        "INSERT INTO grave (row, column, width, height, x, y) VALUES (?, ?, ?, ?, ?, ?)",
        self.position_table[1], self.position_table[2], self.size[1], self.size[2],
        self.position_px[1], self.position_px[2]
    )
    if not result then
        print("Failed to insert grave: " .. self.sqlite_connection_instance:errmsg())
        return nil
    else
        return self.sqlite_connection_instance:getlastautoid()
    end
end

function Grave:dead_locations_add(name, year)
    local dead_location = DeadLocation(
        self.id, name, year, nil,
        self.sqlite_connection_instance
    )
    table.insert(self.dead_locations, dead_location)
end

function Grave:dead_locations_sort(func)
    table.sort(self.dead_locations, func)
end

---@param params {name?:string,year?:number,id?:number}: Parameters to match for removal
function Grave:dead_locations_rm(params)
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
            self.sqlite_connection_instance:execute(rm_query)
            table.remove(self.dead_locations, i)
        end
    end
end


return Grave