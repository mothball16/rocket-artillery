--#region required
local dirServer = require(script.Parent.Parent.Parent.Directory)
local dir = dirServer.Main
local validator = dir.Validator.new(script.Name)
local AttachSelector = require(dir.Modules.AttachmentSystem.AttachSelector)
local AttachServerController = require(dirServer.Root.Modules.AttachmentSystem.AttachServerController)
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

local function SetupSlot(attacher, slot, initLoaded)
    if initLoaded then
        validator:Warn("TODO: un-hardcode the projectile selection")
        local result = attacher:AttachAt(nil, tonumber(slot.Name), "9M27F")
        print(result)
    end
end

-- TODO: we don't need attachselector initialized here
function TurretServerController.new(args, required)
    local self = setmetatable({}, TurretServerController)
    self.AttachSelector = AttachSelector.new(args.AttachSelector, required)
    self.AttachServerController = AttachServerController.new(args.AttachServerController, required)
    for _, slot in pairs(self.AttachSelector:GetSlots():GetChildren()) do
        SetupSlot(self.AttachServerController, slot, true)
    end
    return self
end

function TurretServerController:Destroy()
    maid:DoCleaning()
end

return TurretServerController