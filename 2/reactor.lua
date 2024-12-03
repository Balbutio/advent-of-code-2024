package.path = package.path .. ";../?.lua"
require "file-utility"

EQUAL = "2"
INCREASING = "1"
DECREASING = "0"

function get_safe_reports(contents, withProblemDampener)
    local reports = {}
    local safeReports = 0
    local isSafe = false
    for line in string.gmatch(contents, "[^\r\n]+") do
        isSafe = is_report_line_safe(line, withProblemDampener)
        if (isSafe == true) then
            safeReports = safeReports + 1
        end
    end
    return safeReports
end

function is_report_line_safe(line, withProblemDampener)
    local report = {}
    
    for currentValue in string.gmatch(line, "(%d+)") do
        table.insert(report, tonumber(currentValue))
    end

    local isSafe, badKey = is_report_safe(report)
    if ((isSafe == false) and (withProblemDampener == true)) then

        -- Retry removing current value
        local removedValue = report[badKey]
        report[badKey] = nil
        isSafe = is_report_safe(report)
        if (isSafe == true) then
            return true 
        end

        -- Retry removing previous value
        report[badKey] = removedValue
        removedValue = report[badKey-1] 
        report[badKey-1] = nil
        isSafe = is_report_safe(report)
        if (isSafe == true) then
            return true 
        end

        -- Retry removing first value
        report[badKey-1] = removedValue
        removedValue = report[1] 
        report[1] = nil
        isSafe = is_report_safe(report)
        if (isSafe == true) then
            return true 
        end
    end

    return isSafe
end

function is_report_safe(report)
    local previousValue = nil
    local pattern = nil
    for key, currentValue in pairs(report) do
        if (previousValue ~= nil) then
            -- Assign pattern if not set
            if (pattern == nil) then
                pattern = get_sequence_direction(currentValue, previousValue)
                if (pattern == EQUAL) then
                    return false, currentValue
                end
            end
            -- Assess values
            if ((pattern == INCREASING) and (currentValue > previousValue)) then
                if ((currentValue - previousValue) > 3) then
                    -- Increase bigger than 3
                    return false, key
                end
            elseif ((pattern == DECREASING) and (currentValue < previousValue)) then
                if ((previousValue - currentValue) > 3) then
                    -- Decrease bigger than 3
                    return false, key
                end
            else
                -- Inconsistent pattern
                return false, key
            end
        end
        previousValue = currentValue
    end
    return true, nil
end

function get_sequence_direction(currentValue, previousValue)
    if (currentValue > previousValue) then
        pattern = INCREASING
    elseif (currentValue < previousValue) then
        pattern = DECREASING
    else
        pattern = EQUAL
    end
    return pattern
end

local file = "input.txt"
local contents = read_all(file)
print("Safe Reports: " .. get_safe_reports(contents, false))
print("Safe Reports (with Problem Dampener): " .. get_safe_reports(contents, true))
