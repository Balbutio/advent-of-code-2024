package.path = package.path .. ";../?.lua"
require "file-utility"

function get_lines(data)
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

function get_update_totals(rules, updates)
    local validUpdateTotal = 0
    local invalidUpdateTotal = 0
    for sequenceKey, updateSequence in pairs(updates) do

        local validSequence, errorIndex = test_sequence_validity(updateSequence, rules)
        if (validSequence ~= nil) then
            validUpdateTotal = validUpdateTotal + get_middle_value(validSequence)
        elseif (errorIndex ~= nil) then
            local newSequence = updateSequence
            local previousSequence = {}
            while ((validSequence == nil) and (previousSequence ~= newSequence)) do
                newSequence = update_sequence_validity(newSequence, rules, errorIndex)
                validSequence, errorIndex = test_sequence_validity(newSequence, rules)
            end
            if (validSequence ~= nil) then
                invalidUpdateTotal = invalidUpdateTotal + get_middle_value(validSequence)
            end
        end
    end
    return validUpdateTotal, invalidUpdateTotal
end

function get_middle_value(validSequence)
    local targetIndex = ((math.floor(#validSequence/2))+1)
    return validSequence[targetIndex]
end

function test_sequence_validity(updateSequence, rules)
    local previousUpdateValues = {}
    local validSequence = true
    local errorIndex = nil
    for updateIndex, updateValue in pairs(updateSequence) do
        if (#previousUpdateValues ~= nil) then
            if is_invalid_sequence(rules, updateValue, previousUpdateValues) then
                validSequence = false
                errorIndex = updateIndex
                break
            end
        end
        table.insert(previousUpdateValues, updateValue)
    end
    if (validSequence == true) then
        return previousUpdateValues, nil
    else
        return nil, errorIndex
    end
end

function is_invalid_sequence(table, key, previousUpdateValues)
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

function update_sequence_validity(updateSequence, rules, errorIndex)
    if (updateSequence[errorIndex - 1] ~= nil) then
        updateSequence[errorIndex - 1], updateSequence[errorIndex] = updateSequence[errorIndex], updateSequence[errorIndex - 1]
        return updateSequence
    else 
        return nil 
    end
end

local ruleLines = {}
local updateLines = {}
local rules = {}
local updates = {}
local validUpdateTotal = 0
local invalidUpdateTotal = 0

local file = "input.txt"
local contents = read_all(file)
ruleLines, updateLines = get_lines(contents)
rules = parse_rules(ruleLines)
updates = parse_updates(updateLines)
validUpdateTotal, invalidUpdateTotal = get_update_totals(rules, updates)
print("Valid total: " .. validUpdateTotal)
print("Invalid total: " .. invalidUpdateTotal)

