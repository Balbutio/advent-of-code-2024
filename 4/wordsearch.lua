package.path = package.path .. ";../?.lua"
require "file-utility"

DIRECTION_NONE = 0
DIRECTION_LEFT = 1
DIRECTION_TOP_LEFT = 2
DIRECTION_TOP = 3
DIRECTION_TOP_RIGHT = 4
DIRECTION_RIGHT = 5
DIRECTION_BOTTOM_RIGHT = 6
DIRECTION_BOTTOM = 7
DIRECTION_BOTTOM_LEFT = 8

XMAS = 0
X_MAS = 1

function build_wordsearch_matrix(data)
    local matrix = {}
    local y = 1
    local x = 1
    for line in string.gmatch(data, "[^\r\n]+") do
        x = 1
        matrix[y] = {}
        for char in string.gmatch(line, ".") do
            matrix[y][x] = char
            x = x + 1
        end
        y = y + 1
    end
    return matrix
end

function parse_wordsearch_matrix(searchType, matrix, targetLetter)
    local matches = 0
    for yKey, line in pairs(matrix) do
        for xKey, character in pairs(line) do
            if (character == targetLetter) then
                if (searchType == XMAS) then
                    matches = matches + analyse_word_connections(matrix, yKey, xKey, 2, DIRECTION_NONE)
                elseif (searchType == X_MAS) then
                    matches = matches + analyse_cross_connections(matrix, yKey, xKey)
                end
            end
        end
    end
    return matches
end

function analyse_word_connections(matrix, yKey, xKey, targetLetterIndex, direction)
    if (targetLetterIndex <= targetWordLength) then
        local targetLetter = string.sub(targetWord, targetLetterIndex, targetLetterIndex)

        if (direction == DIRECTION_NONE) then
            local matches = 0
            matches = analyse_word_connections(matrix, yKey, xKey, targetLetterIndex, DIRECTION_LEFT)
            matches = matches + analyse_word_connections(matrix, yKey, xKey, targetLetterIndex, DIRECTION_TOP_LEFT)
            matches = matches + analyse_word_connections(matrix, yKey, xKey, targetLetterIndex, DIRECTION_TOP)
            matches = matches + analyse_word_connections(matrix, yKey, xKey, targetLetterIndex, DIRECTION_TOP_RIGHT)
            matches = matches + analyse_word_connections(matrix, yKey, xKey, targetLetterIndex, DIRECTION_RIGHT)
            matches = matches + analyse_word_connections(matrix, yKey, xKey, targetLetterIndex, DIRECTION_BOTTOM_RIGHT)
            matches = matches + analyse_word_connections(matrix, yKey, xKey, targetLetterIndex, DIRECTION_BOTTOM)
            matches = matches + analyse_word_connections(matrix, yKey, xKey, targetLetterIndex, DIRECTION_BOTTOM_LEFT)
            return matches
        else
            yKey, xKey = new_coordinates(yKey, xKey, direction)
            if ((matrix[yKey] == nil) or (matrix[yKey][xKey] == nil) or (matrix[yKey][xKey] ~= targetLetter)) then
                return 0
            else
                return analyse_word_connections(matrix, yKey, xKey, targetLetterIndex+1, direction)
            end            
        end
    else
        return 1
    end
end

function new_coordinates(yKey, xKey, direction)
    if (direction == DIRECTION_LEFT) then
        return yKey, xKey-1
    elseif (direction == DIRECTION_TOP_LEFT) then
        return yKey-1, xKey-1
    elseif (direction == DIRECTION_TOP) then
        return yKey-1, xKey
    elseif (direction == DIRECTION_TOP_RIGHT) then
        return yKey-1, xKey+1
    elseif (direction == DIRECTION_RIGHT) then
        return yKey, xKey+1
    elseif (direction == DIRECTION_BOTTOM_RIGHT) then
        return yKey+1, xKey+1
    elseif (direction == DIRECTION_BOTTOM) then
        return yKey+1, xKey
    elseif (direction == DIRECTION_BOTTOM_LEFT) then
        return yKey+1, xKey-1
    end
end

function analyse_cross_connections(matrix, yKey, xKey)
    local yKeyA, xKeyA = new_coordinates(yKey, xKey, DIRECTION_TOP_LEFT)
    local yKeyB, xKeyB = new_coordinates(yKey, xKey, DIRECTION_TOP_RIGHT)
    local yKeyC, xKeyC = new_coordinates(yKey, xKey, DIRECTION_BOTTOM_LEFT)
    local yKeyD, xKeyD = new_coordinates(yKey, xKey, DIRECTION_BOTTOM_RIGHT)

    local findingA = validate_cross_point(matrix, yKeyA, xKeyA, nil)
    if (findingA ~= false) then
        local findingB = validate_cross_point(matrix, yKeyB, xKeyB, nil)
        local findingC = validate_cross_point(matrix, yKeyC, xKeyC, nil)
        if (findingB ~= false and findingC ~= false) then
            if (findingA == findingB) then
                local findingD = validate_cross_point(matrix, yKeyD, xKeyD, findingC)
                if ((findingD == findingC) and (findingD == get_opposite_cross_character(findingA))) then
                    return 1
                end
            elseif (findingA == findingC) then
                local findingD = validate_cross_point(matrix, yKeyD, xKeyD, findingB)
                if ((findingD == findingB) and (findingD == get_opposite_cross_character(findingA))) then
                    return 1
                end
            end
        end
    end
    return 0
end

function validate_cross_point(matrix, yKey, xKey, targetLetter)
    if ((matrix[yKey] ~= nil) and (matrix[yKey][xKey] ~= nil)) then
        if (targetLetter == nil) then
            --print(yKey, xKey, targetLetter)
            if (matrix[yKey][xKey] == targetCrossAlt1) then
                return targetCrossAlt1
            elseif (matrix[yKey][xKey] == targetCrossAlt2) then
                return targetCrossAlt2
            end
        else
            if (matrix[yKey][xKey] == targetLetter) then
                return targetLetter
            end
        end
    end
    return false
end

function get_opposite_cross_character(letter)
    if (letter == targetCrossAlt1) then
        return targetCrossAlt2
    elseif (letter == targetCrossAlt2) then
        return targetCrossAlt1
    end
end

local file = "input.txt"
local contents = read_all(file)
local wordsearchMatrix = build_wordsearch_matrix(contents)

targetWord = "XMAS"
targetWordLength = string.len(targetWord)

targetCenter = "A"
targetCrossAlt1 = "M"
targetCrossAlt2 = "S"

print("XMAS Matches: " .. parse_wordsearch_matrix(XMAS, wordsearchMatrix, string.sub(targetWord, 1, 1)))
print("X-MAS Matches: " .. parse_wordsearch_matrix(X_MAS, wordsearchMatrix, targetCenter))