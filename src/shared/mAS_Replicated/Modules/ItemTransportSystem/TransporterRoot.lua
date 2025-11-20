--#region required
local dir = require(script.Parent.Parent.Parent.Directory)
local validator = dir.Validator.new(script.Name)
local AttachServerController = require(dir.Modules.AttachmentSystem.AttachServerController)
--#endregion required
--[[
This is the purpose of this script.
]]

local component = {}
component.__index = component

local function _checkSetup(required)
    
end
function component.new(args, required)
    local self = setmetatable({}, component)
    self.AttachServerController = AttachServerController.new(args, required)
    return self
end

return component