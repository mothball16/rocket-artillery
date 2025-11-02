--#region required
local dir = require(script.Parent.Parent.Parent.Directory)
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
given an origin and a target position, calculates the correct angle and rotation
aka the fucking cheater script
]]

local component = {}
component.__index = component

local function _checkSetup(required)
    
end
function component.new(args, required)
    local self = setmetatable({}, component)
    
    return self
end

return component