--#region required
local dir = require(script.Parent.Parent.Parent.Directory)
local validator = dir.Validator.new(script.Name)
local template = dir.Assets.UI.Visualizer
local AttachSelector = require(script.Parent.AttachSelector)
--#endregion required
--[[
visualizes the attachment slots for like attach/detach purposes
]]

local component = {}
component.__index = component

local function _checkSetup(required)
    
    return 
end
function component.new(args : {
    interactible: boolean
}, required)
    local self = setmetatable({}, component)

    if self.interactible then
        
    end
    return self
end

function component:ReadSelector(selector: typeof(AttachSelector))
    local slots = selector:GetSlots()
    for i, v in pairs(slots) do
        
    end
end

function component:SetupConnections()
    
end

function component:Destroy()
    
end

return component