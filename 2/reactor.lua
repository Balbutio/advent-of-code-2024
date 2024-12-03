package.path = package.path .. ";../?.lua"
require "file-utility"

INCREASING = "1"
DECREASING = "0"

function get_safe_reports(contents)
    local reports = {}
    local safeReports = 0
    local isSafe = false
    for line in string.gmatch(contents, "[^\r\n]+") do
        isSafe = is_report_line_safe(line)
        if (isSafe == true) then
            safeReports = safeReports + 1
        end
    end
    return safeReports
end

function is_report_line_safe(line)
    local report = {}
    
    for currentValue in string.gmatch(line, "(%d+)") do
        table.insert(report, tonumber(currentValue))
    end

    local isSafe, badKey = is_report_safe(report)
    if (isSafe == false) then

        local value = report[badKey] 
        
        -- Retry removing current value
        report[badKey] = nil
        isSafe = is_report_safe(report)
        if (isSafe == true) then return true end

        -- Retry removing previous value
        report[badKey] = value
        value = report[badKey-1] 
        report[badKey-1] = nil
        isSafe = is_report_safe(report)
        if (isSafe == true) then return true end

        -- Retry removing first value
        report[badKey-1] = value
        value = report[1] 
        report[1] = nil
        isSafe = is_report_safe(report)
        if (isSafe == true) then return true end
    end
    return isSafe
end

function is_report_safe(report)
    local previousValue = nil
    local pattern = nil
    for key, currentValue in pairs(report) do
        if (previousValue ~= nil) then
            -- Assign pattern
            if (pattern == nil) then
                if (currentValue > previousValue) then
                    if ((currentValue - previousValue) > 3) then
                        return false, key
                    else
                        pattern = INCREASING
                    end
                elseif (currentValue < previousValue) then
                    if ((previousValue - currentValue) > 3) then
                        return false, key
                    else
                        pattern = DECREASING
                    end
                else
                    -- Values are the same
                    return false, key
                end
            -- Pattern already assigned
            else
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
        end
        previousValue = currentValue
    end
    return true, nil
end

local file = "input.txt"
local contents = read_all(file)
local safeReports = get_safe_reports(contents)
print(safeReports)
