package.path = package.path .. ";../?.lua"
require "file-utility"

function get_update_lines(data)
    local ruleLines = {}
    local updateLines = {}

    for line in string.gmatch(data, "[^\r\n]+") do
        if (string.find(line, "|")) then
            table.insert(ruleLines, line)
        elseif (string.find(line, ",")) then
            table.insert(updateLines, line)
        end
    end
    return ruleLines, updateLines
end

function parse_rules(ruleLines)
    local rules = {}
    for key, rule in pairs(ruleLines) do
        left, right = string.match(rule, "(%d+)|(%d+)")
        left = tonumber(left)
        right = tonumber(right)
        if (rules[left] == nil) then
            rules[left] = {}
        end
        table.insert(rules[left], right)
    end
    return rules
end

function parse_updates(updateLines)
    local updates = {}
    for key, update in pairs(updateLines) do
        local updateSequence = {}
        for updateValue in string.gmatch(update, "(%d+)") do
            table.insert(updateSequence, tonumber(updateValue))
        end
        table.insert(updates, updateSequence)
    end
    return updates
end

function get_valid_update_count(rules, updates)
    local validUpdateCount = 0
    for sequenceKey, updateSequence in pairs(updates) do
        local previousUpdateValues = {}
        local validSequence = true
        for updateKey, updateValue in pairs(updateSequence) do
            if (#previousUpdateValues ~= nil) then
                if contains(rules, updateValue, previousUpdateValues) then
                    validSequence = false
                    break
                end
            end
            table.insert(previousUpdateValues, updateValue)
        end
        if (validSequence == true) then
            targetIndex = ((math.floor(#previousUpdateValues/2))+1)
            validUpdateCount = validUpdateCount + previousUpdateValues[targetIndex]
        end
    end
    return validUpdateCount
end

function contains(table, key, previousUpdateValues)
    if (table[key] ~= nil) then
        for x, y in pairs(table[key]) do
            for pX, pY in pairs(previousUpdateValues) do
                if (pY == y) then
                    return true
                end
            end
        end
    end
    return false
end

local ruleLines = {}
local updateLines = {}
local rules = {}
local updates = {}

local file = "input.txt"
local contents = read_all(file)
ruleLines, updateLines = get_update_lines(contents)
rules = parse_rules(ruleLines)
updates = parse_updates(updateLines)
validUpdateCount = get_valid_update_count(rules, updates)
print(validUpdateCount)