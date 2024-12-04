package.path = package.path .. ";../?.lua"
require "file-utility"

function parse_corrupted_data(data, parseEnablers)
    local totalValue = 0
    dataString = build_parsable_input(data)

    if (parseEnablers == true) then
        instructionList = split_instructions(dataString)
        for key, instructions in pairs(instructionList) do
            totalValue = totalValue + parse_calculations(instructions)
        end
    else
        totalValue = parse_calculations(dataString)
    end

    return totalValue
end

function build_parsable_input(data)
    local dataString = "do()"
    for line in string.gmatch(data, "[^\r\n]+") do
        dataString = dataString .. line
    end
    dataString = dataString .. "don't()"
    return dataString
end

function split_instructions(dataString)
    local instructionList = {}
    for instructions in string.gmatch(dataString, "do%(%)(.-)don't%(%)") do
        table.insert(instructionList, instructions)
    end
    return instructionList
end

function parse_calculations(instructions)
    local instructionsTotal = 0
    for x,y in string.gmatch(instructions, "mul%((%d+),(%d+)%)") do
        instructionsTotal = instructionsTotal + (x*y)
    end
    return instructionsTotal
end

local file = "input.txt"
local contents = read_all(file)
print("Initial total: " .. parse_corrupted_data(contents, false))
print("Revised total: " .. parse_corrupted_data(contents, true))