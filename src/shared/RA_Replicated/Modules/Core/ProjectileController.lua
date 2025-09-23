local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local configs = dir.Configs.Projectiles
local models = dir.Assets.Projectiles
local rayParams = RaycastParams.new()
local cache = {}

local ProjectileController = {}


local function GetAssets(name)
    if not cache[name] then
        local config = require(configs:FindFirstChild(name))
        local model = models:FindFirstChild(name)
        assert(config and model, "config or model is mising for projectile " .. name)
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
    assert(data.Config["OnFire"], "ProjectileController fire fail: incorrectly configured projectile config. are you missing OnFire?")

    local projectile = data.Model:Clone()
    projectile.Parent = game.Workspace
    projectile:SetPrimaryPartCFrame(firePart.CFrame)

    for _, behavior in pairs(data.Config.OnFire) do
        behavior:Execute(projectile.PrimaryPart, rayParams)
    end
end

return ProjectileController