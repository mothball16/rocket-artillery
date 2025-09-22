local isStudio = game:GetService("RunService"):IsStudio()
local logger = {}

local function GetInfo()
    -- level 2: the function that called this function
    local info = debug.info(2, "sln") -- source, line, name
    return info
end

function logger.Print(msg)
    if not isStudio then return end
    local callerInfo = GetInfo()
    print(callerInfo .. ": " .. msg)
end

return logger