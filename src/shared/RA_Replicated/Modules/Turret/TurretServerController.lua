--#region required
local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local validator = dir.Validator.new(script.Name)
local AttachSelector = require(dir.Modules.AttachmentSystem.AttachSelector)
local AttachServerController = require(dir.Modules.AttachmentSystem.AttachServerController)
local maid = dir.Maid.new()
--#endregion required
--[[
this is what players interact with regarding the rack
- should only be generated once per turret, so this follows the default cleanup (on obj destroy)
]]

local TurretServerController = {}
TurretServerController.__index = TurretServerController

local function _checkSetup(required)
    
end

local function SetupSlot(attacher, slot)
    local prox = Instance.new("ProximityPrompt")
    prox.Parent = slot
    prox.ActionText = "Slot (" .. slot:GetAttribute("SlotType") .. ")"
    prox.RequiresLineOfSight = false

    maid:GiveTask(prox.Triggered:Connect(function(plr)
        validator:Warn("TODO: un-hardcode the projectile selection")
        local result = attacher:AttachAt(tonumber(slot.Name), "TOS220Short")
    end))
end

-- TODO: we don't need attachselector initialized here
function TurretServerController.new(args, required)
    local self = setmetatable({}, TurretServerController)
    self.AttachSelector = AttachSelector.new(args.AttachSelector, required)
    self.AttachServerController = AttachServerController.new(args.AttachServerController, required)

    for _, slot in pairs(self.AttachSelector:GetSlots():GetChildren()) do
        SetupSlot(self.AttachServerController, slot)
    end
    return self
end

function TurretServerController:Destroy()
    maid:DoCleaning()
end

return TurretServerController