--#region required
local dirClient = require(script.Parent.Parent.Parent.Directory)
local dir = dirClient.Main
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
This is the purpose of this script.
]]

local Gyroscope = {}
Gyroscope.__index = Gyroscope

local fallbacks = {}

local function _checkSetup(required)
    return validator:ValueIsOfClass("MouseAimerBase", "BasePart")
end
function Gyroscope.new(args, required)
    local gyro = _checkSetup(required)
    local self = setmetatable({}, Gyroscope)
    self.config = dir.Helpers:TableOverwrite(fallbacks, args)
    
    return self
end

function Gyroscope:Update(dt)
    
end

return Gyroscope