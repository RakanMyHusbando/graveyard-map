Class = require "class"
SQLite = require "luasql.sqlite3"
Graveyard = require "graveyard"
Grave = require "grave"
DeadLocation = require "dead_location"

local sqlite_db_file = "graveyard.db"

local graveyard = (require "read_from_svg")("graveyard.svg", sqlite_db_file)

local conn = graveyard:sqlite_connection()
local cursor = conn:execute("SELECT * FROM grave")

if cursor then
    print("id", "row", "column", "width", "height", "x", "y")
    local row = cursor:fetch({}, "a")
    while row do row = cursor:fetch(row, "a") end
else
    print("No data found in grave table.")
end

conn:close()