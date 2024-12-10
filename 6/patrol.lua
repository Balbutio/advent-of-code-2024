package.path = package.path .. ";../?.lua"
require "file-utility"

GUARD_FORWARD_AVATAR = "^"
GUARD_RIGHT_AVATAR = ">"
GUARD_BACK_AVATAR = "v"
GUARD_LEFT_AVATAR = "<"

GUARD_PATH_AVATAR = "X"

GUARD_FORWARD = 1
GUARD_RIGHT = 2
GUARD_BACK = 3
GUARD_LEFT = 4

function build_map_matrix(data, guardStartingAvatar)
    local matrix = {}
    local y = 1
    local x = 1
    for line in string.gmatch(data, "[^\r\n]+") do
        x = 1
        matrix[y] = {}
        for char in string.gmatch(line, ".") do
            if (char == guardStartingAvatar) then
                guardY = y
                guardX = x
            end
            matrix[y][x] = char
            x = x + 1
        end
        y = y + 1
    end
    return matrix
end

function count_map_occurrences(map, targetCharacter)
    local characterCount = 0
    for yKey, line in pairs(map) do
        for xKey, value in pairs(line) do
            if (value == targetCharacter) then
                characterCount = characterCount + 1
            end
        end
    end
    return characterCount
end

function get_distinct_guard_positions(map)
    -- add stuck detection (by moving away from recursive call)
    finalMap = move_guard(map, guardY, guardX, guardDirection)
    return count_map_occurrences(finalMap, GUARD_PATH_AVATAR)
end

function move_guard(map, guardY, guardX, guardDirection)
    local targetY = guardY
    local targetX = guardX

    if (guardDirection == GUARD_FORWARD) then
        targetY = guardY - 1
        targetX = guardX
    elseif (guardDirection == GUARD_RIGHT) then
        targetY = guardY
        targetX = guardX + 1
    elseif (guardDirection == GUARD_BACK) then
        targetY = guardY + 1
        targetX = guardX
    elseif (guardDirection == GUARD_LEFT) then
        targetY = guardY
        targetX = guardX - 1
    end

    if ((map[targetY] == nil) or (map[targetY][targetX] == nil)) then
        map[guardY][guardX] = GUARD_PATH_AVATAR
        --print("Edge")
        return map
    elseif (map[targetY][targetX] == "#") then
        local newDirection = turn_guard(guardDirection)
        map[guardY][guardX] = get_guard_avatar(newDirection)
        --print("Blocked: " .. map[targetY][targetX])
        return move_guard(map, guardY, guardX, newDirection)
    else
        map[guardY][guardX] = GUARD_PATH_AVATAR
        map[targetY][targetX] = get_guard_avatar(guardDirection)
        --print("Moving: (" .. targetY .. ", " .. targetX .. ")")
        return move_guard(map, targetY, targetX, guardDirection)
    end
end

function turn_guard(currentDirection)
    if (currentDirection ~= GUARD_LEFT) then
        return currentDirection + 1
    else
        return currentDirection - 3
    end
end

function get_guard_avatar(currentDirection)
    if (currentDirection == GUARD_FORWARD) then
        return GUARD_FORWARD_AVATAR
    elseif(currentDirection == GUARD_RIGHT) then
        return GUARD_RIGHT_AVATAR
    elseif(currentDirection == GUARD_BACK) then
        return GUARD_BACK_AVATAR
    elseif(currentDirection == GUARD_LEFT) then
        return GUARD_LEFT_AVATAR
    end
end

guardY = nil
guardX = nil
guardDirection = GUARD_FORWARD
guardStartingAvatar = get_guard_avatar(guardDirection)

local file = "input.txt"
local contents = read_all(file)
local map = build_map_matrix(contents, guardStartingAvatar)
print("Distinct positions: " .. get_distinct_guard_positions(map))
