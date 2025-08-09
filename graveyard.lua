local Graveyard = Class()

function Graveyard:init(schema_file, db_file)
    self.graves = {}
    self.sqlite_connection_instance = nil
    
    self:set_sqlite_connection(schema_file, db_file)
end

function Graveyard:file_exists(name)
    local f = io.open(name, "r")
    if f then
        io.close(f)
        return true
    else
        return false
    end
end

function Graveyard:set_sqlite_connection(schema_file, db_file)
    local file_exists = self:file_exists(db_file)
    local env = SQLite.sqlite3()
    self.sqlite_connection_instance = env:connect(db_file)
    local schema
    local schema_content = io.open(schema_file, "r")
    if schema_content then
        schema = schema_content:read("*a")
        schema_content:close()
    else
        error("Failed to read schema file: " .. schema_file)
    end
    if not file_exists then
        local result = self.sqlite_connection_instance:execute(schema)
        if not result then
            error("Failed to execute schema: " .. self.sqlite_connection_instance:errmsg())
        end
    end
end

function Graveyard:sqlite_connection()
    if self.sqlite_connection_instance then
        return self.sqlite_connection_instance
    else
        error("SQLite connection is not set.")
    end
end

function Graveyard:grave_add(...)
    local conn = self:sqlite_connection()
    for _, value in ipairs(...) do
        local grave = Grave(
            conn,
            value.position_table,
            value.size,
            value.position_px
        )
        table.insert(self.graves, grave)
    end
end


return Graveyard