--#region requires
local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local AttachSelector = require(script.Parent.AttachSelector)
--#endregion

--[[
rack state authority + plays server effects on racking action
]]
local validator = dir.Validator.new(script.Name)
local attachModels = dir.Assets.ProjectileAttachModels

local AttachServerController = {}
AttachServerController.__index = AttachServerController

local fallbacks = {}

local function _checkSetup(required)
    local attachPoints = validator:ValueIsOfClass(required:FindFirstChild("AttachPoints"), "Folder")
end

-- (args, required)
function AttachServerController.new(args, required)
    local attachPoints = _checkSetup(required)
    local self = setmetatable({}, AttachServerController)
    self.config = dir.FallbackConfig.new(args, fallbacks)
    self.selector = AttachSelector.new(args, required)
    self.attachPoints = attachPoints
    self.required = required
    return self
end

-- (index, attachType)
function AttachServerController:AttachAt(index, attachType)
    local slot = self.selector:SlotAt(index)
    local projectile = dir.ProjRegistry:GetProjectile(attachType)
    if not projectile or not projectile.AttachModel then
        validator.Warn("no projectile/attachmodel found for name " .. attachType)
        return false
    end
    local attachModel = projectile.AttachModel:Clone()
    attachModel.Parent = slot
    dir.Helpers.ExecuteServer(projectile.Config.ServerModelOnAttach, projectile.PrimaryPart, self.required)
    dir.Helpers.Weld(slot, attachModel:FindFirstChild("Attachment")).Name = dir.Consts.ATTACH_WELD_NAME
    return true
end

-- (index)
function AttachServerController:UseAt(index)
    local attachModel, config, weld = self.selector:GetAttachPointDataAt(index)
    if not (attachModel and config and weld) then
        validator.Warn("missing attach, config, or weld on attachpoint " .. index)
        return false
    end
    dir.Helpers.ExecuteServer(config.ServerModelOnUse, attachModel.PrimaryPart, self.required)
    return true
end

-- (index)
function AttachServerController:DetachAt(index)
    local attachModel, config, weld = self.selector:GetAttachPointDataAt(index)
        if not (attachModel and config and weld) then
        validator.Warn("missing attach, config, or weld on attachpoint " .. index)
        return false
    end
    dir.Helpers.ExecuteServer(config.ServerModelOnDetach, attachModel.PrimaryPart, self.required)
    if attachModel then attachModel:Destroy() end
    return true
end


return AttachServerController

