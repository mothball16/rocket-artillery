local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local _, _, validator = dir.GetComponentUtilities(script.Name)
local configs = dir.Configs.Projectiles
local models = dir.Assets.Projectiles
local rayParams = RaycastParams.new()
local cache = {}

local ProjectileController = {}


local function GetAssets(name)
    if not cache[name] then
        local config = require(validator:Exists(configs:FindFirstChild(name),"config for projectile " .. name))
        local model = validator:Exists(models:FindFirstChild(name), "model for projectile " .. name)
        cache[name] = {
            Config = config,
            Model = model
        }
    end
    return cache[name]
end

function ProjectileController.Init()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = false
end

function ProjectileController.Fire(firePart, ammoName)
    local data = GetAssets(ammoName)
    local onFire = validator:Exists(data.Config["OnFire"], "OnFire prop. of config of projectile " .. ammoName)
    local projectile = data.Model:Clone()
    projectile.Parent = game.Workspace
    projectile:SetPrimaryPartCFrame(firePart.CFrame)

    for _, behavior in pairs(onFire) do
        behavior:Execute(projectile.PrimaryPart, rayParams)
    end
end

return ProjectileController