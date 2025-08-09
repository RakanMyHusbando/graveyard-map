local function read_from_svg(svg_file,sqlite_db_file)
    local graveyard = Graveyard("graveyard.sqlite", sqlite_db_file)
    local grave_content = {}
    local row
    for line in io.lines(svg_file) do
        if line:match('<g class="grave_row grave_row_%d+">') then
            row = tonumber(line:match('grave_row_(%d+)'))
        elseif row and line:match('<polygon class="grave grave_%d+ fill_1 stroke_1"') then
            local grave_number = line:match('grave_(%d+)')
            local points = line:match('points="([^"]+)"')
            local coords = {}
            local position_table, size, position_px = {row, grave_number}, {0,0}, {0,0}
            for x, y in points:gmatch("(%d+),(%d+)") do
                table.insert(coords, {tonumber(x), tonumber(y)})
            end
            size = {coords[2][1] - coords[1][1], coords[3][2] - coords[2][2]}
            position_px = {coords[1][1] + size[1] / 2, coords[1][2] + size[2] / 2}
            if grave_number and points then
                table.insert(grave_content, {
                    position_table = position_table,
                    size = size,
                    position_px = position_px
                })
            else
                print("No grave number found in line: " .. line)
            end
        elseif line:match('</g>') then
            row = nil
        end
    end
    graveyard:grave_add(grave_content)
    return graveyard
end

return read_from_svg
