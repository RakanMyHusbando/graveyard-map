print (package.path)

local luasql = require("luasql.sqlite3")

local env = luasql.sqlite3()
local conn = env:connect("test.db")
if conn then
    print("Connected to the database successfully!")
else
    conn:close()
    error("Failed to connect to the database.")
end

local create_grave_table = [[
CREATE TABLE grave (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    row INTEGER NOT NULL,
    column INTEGER NOT NULL,
    width INTEGER NOT NULL,
    height INTEGER NOT NULL,
    x INTEGER NOT NULL,
    y INTEGER NOT NULL
);
]]
local result = conn:execute(create_grave_table)
if result then
    print("Grave table created successfully!")
else
    conn:close()
    error("Failed to create grave table.")
end

local function insertGrave(row, column, width, height, x, y)
    local insert_query = string.format(
        "INSERT INTO grave (row, column, width, height, x, y) VALUES (%d, %d, %d, %d, %d, %d)",
        row, column, width, height, x, y
    )
    local result = conn:execute(insert_query)
    if result then
        print("Grave inserted successfully!")
    else
        error("Failed to insert grave.")
    end
end

local row
for line in io.lines("__graveyard.svg") do
    if line:match('<g class="grave_row grave_row_%d+">') then
        row = tonumber(line:match('grave_row_(%d+)'))
    elseif row and line:match('<polygon class="grave grave_%d+ fill_1 stroke_1"') then
        local grave_number = line:match('grave_(%d+)')
        local points = line:match('points="([^"]+)"')
        if grave_number and points then
            local coords = {}
            local grave = {row=row,column=grave_number,width=0,height=0,x=0,y=0}
            for x, y in points:gmatch("(%d+),(%d+)") do
                table.insert(coords, {tonumber(x), tonumber(y)})
            end
            if coords[1][2] ~= coords[2][2] or
                coords[1][1] ~= coords[4][1] or
                coords[2][1] ~= coords[3][1] or
                coords[4][2] ~= coords[3][2] then
                print("Grave is no cube")
            else
                grave.width = coords[2][1] - coords[1][1]
                grave.height = coords[3][2] - coords[2][2]
                grave.x = coords[1][1] + grave.width / 2
                grave.y = coords[1][2] + grave.height / 2
            end
            insertGrave(grave.row, grave.column, grave.width, grave.height, grave.x, grave.y)
        else
            print("No grave number found in line: " .. line)
        end
    elseif line:match('</g>') then
        row = nil
    end
end


local cursor = conn:execute("SELECT * FROM grave")
if cursor then
    row = cursor:fetch({}, "a")

    while row do
        print(row.id, row.row, row.column, row.width, row.height, row.x, row.y)
        row = cursor:fetch(row, "a")
    end
else
    print("No data found in grave table.")
end


conn:close()