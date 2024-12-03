-- http://lua-users.org/wiki/FileInputOutput
-- Return true if file exists and is readable.
function file_exists(path)
    local file = io.open(path, "rb")
    if file then file:close() end
        return file ~= nil
end

-- http://lua-users.org/wiki/FileInputOutput
-- Read an entire file.
-- Use "a" in Lua 5.3; "*a" in Lua 5.1 and 5.2
function read_all(filename)
    local fh = assert(io.open(filename, "rb"))
    local contents = assert(fh:read(_VERSION <= "Lua 5.2" and "*a" or "a"))
    fh:close()
    return contents
end

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
    print(calculate_distances(leftTable, rightTable, listLength))
elseif (runType == "2" or runType == "s" or runType == "similarity") then
    print(calculate_similarity_score(leftTable, rightTable, listLength))
end
