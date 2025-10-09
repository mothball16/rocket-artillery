local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local validator = dir.Validator.new(script.Name)
local rayParams = RaycastParams.new()
local registry = require(dir.Modules.Core.ProjectileRegistry)
local RequestProjectileSpawn = dir.Net:RemoteEvent(dir.Events.Reliable.RequestProjectileSpawn)
local ProjectileController = {}
-- ()
function ProjectileController:Init()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = false
end
---creates a client model of the projectile and sends a request to the server to replicate
---@param firePart BasePart the origin of the projectile spawn
---@param ammoName string the name corresponding to the projectile type registered in ProjectileRegistry
---@param filterInstances table the instances to ignore when casting rays
function ProjectileController.Fire(firePart, ammoName, filterInstances)
    rayParams.FilterDescendantsInstances = filterInstances
    
    local data = registry:GetProjectile(ammoName)
    local onFire = validator:Exists(data.Config["OnFire"], "OnFire prop. of config of projectile " .. ammoName)
    local projectile = data.Model:Clone()
    projectile.Parent = game.Workspace
    projectile:SetPrimaryPartCFrame(firePart.CFrame)
    RequestProjectileSpawn:FireServer(firePart.CFrame)
    dir.NetUtils:ExecuteOnClient(onFire, projectile.PrimaryPart, rayParams)
end

return ProjectileController