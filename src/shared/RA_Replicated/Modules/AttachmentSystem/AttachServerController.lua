--#region requires
local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local AttachSelector = require(script.Parent.AttachSelector)
local ProjectileRegistry = require(dir.Modules.Core.ProjectileRegistry)
--#endregion

--[[
rack state authority + plays server effects on racking action
]]
local validator = dir.Validator.new(script.Name)
local attachModels = dir.Assets.AttachModels

local AttachServerController = {}
AttachServerController.__index = AttachServerController

local fallbacks = {}

-- (args, required)
function AttachServerController.new(args, required)
    local self = setmetatable({}, AttachServerController)
    self.config = dir.FallbackConfig.new(args, fallbacks)
    self.selector = AttachSelector.new(args, required)
    self.required = required
    return self
end

-- (index, attachType)
function AttachServerController:AttachAt(actor, index, attachType)
    local slot = validator:Exists(self.selector:SlotAt(index),"slot at index " .. index)
    if self.selector:SlotOccupied(slot) then
        return false
    end
    local projectile = ProjectileRegistry:GetProjectile(attachType)
    if not projectile or not projectile.AttachModel then
        validator:Warn("no projectile/attachmodel found for name " .. attachType)
        return false
    end

    local instance = projectile.AttachModel:Clone()
    instance.Parent = slot
    instance:SetPrimaryPartCFrame(slot.CFrame)

    slot:SetAttribute("Occupied", true)
    dir.NetUtils:ExecuteOnServer(actor, projectile.Config["ServerModelOnAttach"], projectile.PrimaryPart, self.required)
    dir.Helpers:Weld(slot, instance:FindFirstChild("Attachment")).Name = dir.Consts.ATTACH_WELD_NAME
    return true
end

-- (index)
function AttachServerController:UseAt(actor, index)
    local instance, projectile, weld = self.selector:GetAttachPointDataAt(index)
    if not (instance and projectile and weld) then
        validator:Warn("missing attach, config, or weld on attachpoint " .. index)
        return false
    end
    dir.NetUtils:ExecuteOnServer(actor, projectile.Config["ServerModelOnUse"], instance.PrimaryPart, self.required)
    return true
end

-- (index)
function AttachServerController:DetachAt(actor, index)
    local slot = self.selector:SlotAt(index)
    local instance, projectile, weld = self.selector:GetAttachPointDataAt(index)
    if not (instance and projectile and weld) then
        validator:Warn("missing attach, config, or weld on attachpoint " .. index)
        return false
    end
    if not self.selector:SlotOccupied(slot) then
        return false
    end
    weld:Destroy()
    slot:SetAttribute("Occupied", false)
    dir.NetUtils:ExecuteOnServer(actor, projectile.Config["ServerModelOnDetach"], instance.PrimaryPart, self.required)
    if instance then
        -- let client side replication grab the particles if needed
        instance.Parent = game.ReplicatedStorage
        game.Debris:AddItem(instance, 8)
        end
    return true
end


return AttachServerController

