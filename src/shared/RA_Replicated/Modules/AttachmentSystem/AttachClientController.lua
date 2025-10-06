--#region requires
local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local AttachSelector = require(script.Parent.AttachSelector)
-- local RequestAttachmentAttach = dir.Net:RemoteEvent(dir.Events.Reliable.RequestAttachmentAttach)
local RequestAttachmentUse = dir.Net:RemoteEvent(dir.Events.Reliable.RequestAttachmentUse)
local RequestAttachmentDetach = dir.Net:RemoteEvent(dir.Events.Reliable.RequestAttachmentDetach)
--#endregion

--[[
client bridge to AttachServerController
no authority over anything but can fire off visuals and send action requests over to the server
cannot attach (this isn't an action that requires instantaneous feedback)
]]
local validator = dir.Validator.new(script.Name)

local AttachClientController = {}
AttachClientController.__index = AttachClientController

local fallbacks = {}

-- (args, required)
function AttachClientController.new(args, required)
    local self = setmetatable({}, AttachClientController)
    self.id = dir.NetUtils:GetId(required)
    self.config = dir.FallbackConfig.new(args, fallbacks)
    self.AttachSelector = AttachSelector.new(args, required)
    self.required = required
    return self
end

-- (index, attachType)
function AttachClientController:FireOff(attachType)
    -- finds out what our next slot will be
    local nextFilledSlot = self.AttachSelector:FindNextFull(attachType)
    if not (nextFilledSlot and self.AttachSelector:SlotOccupied(nextFilledSlot)) then
        return false
    end
    local slotIndex = tonumber(nextFilledSlot.Name)

    -- (fireoff is mostly just a shortcut to do this for API clarity)
    return (self:UseAt(slotIndex) and self:DetachAt(slotIndex)), nextFilledSlot
end

-- (index)
function AttachClientController:UseAt(index)
    local instance, projectile, weld = self.AttachSelector:GetAttachPointDataAt(index)
    if not (instance and projectile and weld) then
        validator:Warn("missing attach, config, or weld on attachpoint " .. index)
        return false
    end
    dir.NetUtils:ExecuteOnClient(projectile.Config["ClientModelOnUse"], instance.PrimaryPart, self.required)
    RequestAttachmentUse:FireServer(self.id, index)
    return true
end

-- (index)
function AttachClientController:DetachAt(index)
    local instance, projectile, weld = self.AttachSelector:GetAttachPointDataAt(index)
    if not (instance and projectile and weld) then
        validator:Warn("missing attach, config, or weld on attachpoint " .. index)
        return false
    end
    -- client should invalidate an attempt to fire off the same slot immediately rather
    -- than waiting on the server to update
    self.AttachSelector:SlotAt(index):SetAttribute("Occupied", false)
    -- go execute the client effects and tell the servercontroller to upd.
    dir.NetUtils:ExecuteOnClient(projectile.Config["ClientModelOnDetach"], instance.PrimaryPart, self.required)
    RequestAttachmentDetach:FireServer(self.id, index)
    return true
end

function AttachClientController:Destroy()
    
end

return AttachClientController

