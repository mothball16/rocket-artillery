--#region requires
local dirClient = require(script.Parent.Parent.Parent.Directory)
local dir = dirClient.Main
local AttachSelector = require(dir.Modules.AttachmentSystem.AttachSelector)
local Signal = require(dir.Utility.Signal)
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

local function _setupRackListeners(self)
    for _, slot: BasePart in pairs(self.AttachSelector:GetSlots():GetChildren()) do
        assert(slot:GetAttribute(dir.Consts.SLOT_TYPE_ATTR) ~= nil, "slot " .. slot.Name .. "is missing slot type attribute")
        self.maid:GiveTask(slot.AttributeChanged:Connect(function(attribute)
            if attribute == dir.Consts.SLOT_OCCUPIED_ATTR then
                self.rackedProjectiles = self.AttachSelector:GetSlotsByID()
                print("refreshed rack state")
                self.localSignals.OnRackUpdated:Fire(self.rackedProjectiles)
            end
        end))
    end
end

function AttachClientController.new(args, required)
    local self = setmetatable({
        id = dir.NetUtils:GetId(required),
        config = dir.Helpers:TableOverwrite(fallbacks, args),
        required = required,
        maid = dir.Maid.new(),
    }, AttachClientController)
    self.AttachSelector = AttachSelector.new(self.config, required)
    self.rackedProjectiles = self.AttachSelector:GetSlotsByID()
    self.localSignals = {OnRackUpdated = Signal.new()}
    _setupRackListeners(self)
    return self
end

function AttachClientController:FireAt(attachType)
    if attachType == nil then return false end

    -- finds out what our next slot will be
    local nextFilledSlot = self.AttachSelector:FindNextFull(attachType)
    if not (nextFilledSlot and self.AttachSelector:SlotOccupied(nextFilledSlot)) then
        return false
    end
    local slotIndex = tonumber(nextFilledSlot.Name)

    -- (fireoff is mostly just a shortcut to do this for API clarity)
    return (self:UseAt(slotIndex) and self:DetachAt(slotIndex)), nextFilledSlot
end

function AttachClientController:UseAt(index)
    local instance, projectile, weld = self.AttachSelector:GetAttachPointDataAt(index)
    if not (instance and projectile and weld) then
        validator:Warn("missing attach, config, or weld on attachpoint " .. index)
        return false
    end
    dir.NetUtils:ExecuteOnClient(projectile.Config["ClientModelOnUse"], {
        ["object"] = instance,
        ["required"] = self.required
    })
    RequestAttachmentUse:FireServer(self.id, index)
    return true
end

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
    dir.NetUtils:ExecuteOnClient(projectile.Config["ClientModelOnDetach"], {
        ["object"] = instance,
        ["required"] = self.required
    })
    RequestAttachmentDetach:FireServer(self.id, index)
    return true
end

function AttachClientController:Destroy()
    self.maid:DoCleaning()
end

return AttachClientController

