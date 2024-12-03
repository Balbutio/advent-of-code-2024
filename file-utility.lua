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