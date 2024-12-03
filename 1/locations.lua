package.path = package.path .. ";../?.lua"
require "file-utility"

function split_lists(contents)
    local leftTable = {}
    local rightTable = {}
    local listLength = 0
    for left, right in string.gmatch(contents, "(%d+)%s+(%d+)") do
        table.insert(leftTable, left)
        table.insert(rightTable, right)
        listLength = listLength + 1
    end
    return leftTable, rightTable, listLength
end

function calculate_distances(leftTable, rightTable, listLength)
    local totalDistance = 0
    local distance = 0
    for i = 1, listLength, 1 do
        distance = 0
        if (leftTable[i] < rightTable[i]) then 
            distance = rightTable[i] - leftTable[i]
        elseif (leftTable[i] > rightTable[i]) then
            distance = leftTable[i] - rightTable[i]
        end
        totalDistance = totalDistance + distance
    end
    return totalDistance
end

function calculate_similarity_score(leftTable, rightTable, listLength)
    local totalSimilarity = 0
    local occurrences = 0
    for i = 1, listLength, 1 do
        occurrences = 0
        for x,y in pairs(rightTable) do
            if(y == leftTable[i]) then
                occurrences = occurrences + 1
            end
        end
        totalSimilarity = totalSimilarity + (leftTable[i] * occurrences)
    end
    return totalSimilarity
end

local runType = arg[1]
local file = "input.txt"
local contents = read_all(file)
local leftTable, rightTable, listLength = split_lists(contents)

if (runType == "1" or runType == "d" or runType == "distance") then
    table.sort(leftTable)
    table.sort(rightTable)
    print("Total Distance: " .. calculate_distances(leftTable, rightTable, listLength))
elseif (runType == "2" or runType == "s" or runType == "similarity") then
    print("Similarity Score: " .. calculate_similarity_score(leftTable, rightTable, listLength))
end
