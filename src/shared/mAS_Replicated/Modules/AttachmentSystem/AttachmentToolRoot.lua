local CollectionService = game:GetService("CollectionService")
--#region required
local dir = require(script.Parent.Parent.Parent.Directory)
local validator = dir.Validator.new(script.Name)
local AttachSelector = require(dir.Modules.AttachmentSystem.AttachSelector)
--#endregion required
--[[

]]

local fallbacks = {}

local AttachmentTool = {}
AttachmentTool.__index = AttachmentTool

local function _checkSetup(required)
    return
end

local function _toggleInteractionPoints(enabled: boolean)
    for _, interact in ipairs(CollectionService:GetTagged(dir.Consts.SELECTOR_INTERACT_ATTR)) do
        local prox = interact:FindFirstChildOfClass("ProximityPrompt")
        if not prox then return end
        prox.Enabled = enabled
    end
end

function AttachmentTool.new(args : {
    interactible: boolean
}, required)
    local self = setmetatable({}, AttachmentTool)
    self.config = dir.Helpers:TableOverwrite(fallbacks, args)
    _toggleInteractionPoints(true)
    return self
end

function AttachmentTool:ReadSelector(selector: typeof(AttachSelector))
    local slots = selector:GetSlots()
    for i, v in pairs(slots) do
        
    end
end

function AttachmentTool:SetupConnections()
    
end

function AttachmentTool:Destroy()
    _toggleInteractionPoints(false)
end

return AttachmentTool