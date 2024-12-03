package.path = package.path .. ";../?.lua"
require "file-utility"

function find_multiplications(contents)
    local total = 0
    for line in string.gmatch(contents, "[^\r\n]+") do
        total = total + find_line_total(line)
    end
    return total
end

function find_line_total(line)
    local lineTotal = 0
    for x,y in string.gmatch(line, "mul%((%d+),(%d+)%)") do
        lineTotal = lineTotal + (x*y)
    end
    return lineTotal
end

local file = "input.txt"
local contents = read_all(file)
print("Total: " .. find_multiplications(contents))