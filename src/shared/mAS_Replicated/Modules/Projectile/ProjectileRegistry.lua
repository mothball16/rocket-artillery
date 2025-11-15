-- lazy-loads projectile configs for easy retrieval
local dir = require(script.Parent.Parent.Parent.Directory)
local validator = require(dir.Utility.Validator)
local configs = dir.Configs.Projectiles
local models = dir.Assets.Projectiles
local attachModels = dir.Assets.AttachModels
local cache = {}

local ProjectileRegistry = {}

-- (name)
function ProjectileRegistry:GetProjectile(name)
    if not cache[name] then
        local config = require(validator:Exists(
            configs:FindFirstChild(name),"config for projectile " .. name))
        local model = validator:Exists(models:FindFirstChild(name), "model for projectile " .. name)
        cache[name] = {
            Config = config,
            Model = model,
            AttachModel = attachModels:FindFirstChild(name)
        }
    end
    return cache[name]
end

return ProjectileRegistry