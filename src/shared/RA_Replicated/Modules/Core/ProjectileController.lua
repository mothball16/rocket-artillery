local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local validator = dir.Validator.new(script.Name)
local rayParams = RaycastParams.new()
local registry = require(dir.Modules.Core.ProjectileRegistry)

local ProjectileController = {}

-- ()
function ProjectileController:Init()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = false
end

-- (firePart, ammoName)
function ProjectileController.Fire(firePart, ammoName)
    local data = registry:GetProjectile(ammoName)
    local onFire = validator:Exists(data.Config["OnFire"], "OnFire prop. of config of projectile " .. ammoName)
    local projectile = data.Model:Clone()
    projectile.Parent = game.Workspace
    projectile:SetPrimaryPartCFrame(firePart.CFrame)

    dir.Helpers:ExecuteClient(onFire, projectile.PrimaryPart, rayParams)
end

return ProjectileController