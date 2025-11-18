local CollectionService = game:GetService("CollectionService")
--#region requires
local dir = require(script.Parent.Parent.Parent.Directory)
local AttachSelector = require(script.Parent.AttachSelector)
local ProjectileRegistry = require(dir.Modules.Projectile.ProjectileRegistry)
--#endregion

--[[
rack state authority + plays server effects on racking action
]]
local validator = dir.Validator.new(script.Name)
local attachModels = dir.Assets.AttachModels

local AttachServerController = {}
AttachServerController.__index = AttachServerController

local fallbacks = {
    activationDistance = 10,
    holdDuration = 0.5,
}


local function _checkSetup(required)
    local attachInteractionPoint = validator:ValueIsOfClass(required:FindFirstChild("AttachInteractionPoint"), "BasePart")
    return attachInteractionPoint
end



function AttachServerController.new(args, required)
    local self = setmetatable({
        config = dir.Helpers:TableOverwrite(fallbacks, args),
        selector = AttachSelector.new(args, required),
        required = required,
        attachInteractionPoint = _checkSetup(required),
        proxInUse = false
    }, AttachServerController)

    self:SetupAttachInteractionPoint(self.attachInteractionPoint)
    return self
end


function AttachServerController:SetupAttachInteractionPoint(part)
    local prox = Instance.new("ProximityPrompt")
    CollectionService:AddTag(part, dir.Consts.SELECTOR_INTERACT_ATTR)
    prox.Parent = part
    prox.Enabled = false -- clients will enable when they have the tool equipped
    prox.ActionText = "Manage Attachments"
    prox.RequiresLineOfSight = false
    prox.HoldDuration = self.config.holdDuration
    prox.MaxActivationDistance = self.config.activationDistance
    prox.Triggered:Connect(function(player)
        if self.proxInUse then
            return
        end
        self.proxInUse = true
        prox.ObjectText = "Slots (under use by " .. player.Name .. ")"
    end)
    return prox
end

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
    dir.NetUtils:ExecuteOnServer(actor, projectile.Config["ServerModelOnAttach"], {
        ["object"] = instance,
        ["required"] = self.required
    })
    dir.Helpers:Weld(slot, instance:FindFirstChild("Attachment")).Name = dir.Consts.ATTACH_WELD_NAME
    --dir.NetUtils:FireOtherClients(actor, dir.Events.Reliable.OnAttachStateModified, self.required)
    return true
end

-- (index)
function AttachServerController:UseAt(actor, index)
    local instance, projectile, weld = self.selector:GetAttachPointDataAt(index)
    if not (instance and projectile and weld) then
        validator:Warn("missing attach, config, or weld on attachpoint " .. index)
        return false
    end
    dir.NetUtils:ExecuteOnServer(actor, projectile.Config["ServerModelOnUse"], {
        ["object"] = instance,
        ["required"] = self.required
    })
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
    dir.NetUtils:ExecuteOnServer(actor, projectile.Config["ServerModelOnDetach"], {
        ["object"] = instance,
        ["required"] = self.required
    })
    if instance then
        -- let client side replication grab the particles if needed
        instance.Parent = game.ReplicatedStorage
        game.Debris:AddItem(instance, 8)
    end
    --dir.NetUtils:FireOtherClients(actor, dir.Events.Reliable.OnAttachStateModified, self.required)
    return true
end


return AttachServerController

