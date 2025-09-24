local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local maid, conf, validator = dir.GetComponentUtilities(script.Name)
local AmmoSlots = {}
AmmoSlots.__index = AmmoSlots

local fallbacks = {
    
}

local function _checkSetup(required)
    local ammoRack = validator:IsOfClass(required:FindFirstChild("AmmoRack"), "Folder")
    for _, slot in pairs(ammoRack:GetChildren()) do
        validator:IsOfClass(slot, "BasePart")
        validator:HasAttr(slot, "SlotType")
    end
    return ammoRack
end

function AmmoSlots.new(args, required)
    local ammoRack = _checkSetup(required)
    local self = {}
    self.slot = 1
    self.config = conf.new(args, fallbacks)
    self.ammoRack = ammoRack
    return self
end

return AmmoSlots