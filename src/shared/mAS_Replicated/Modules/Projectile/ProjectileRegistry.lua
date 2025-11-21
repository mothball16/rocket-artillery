-- lazy-loads projectile configs for easy retrieval
local dir = require(script.Parent.Parent.Parent.Directory)
local validator = require(dir.Utility.Validator)
local configs = dir.Configs.Projectiles
local models = dir.Assets.Projectiles
local attachModels = dir.Assets.AttachModels
local cache = {}
local cacheBySlot = {}
local ProjectileRegistry = {}
local IGNORE_IN__CONFIG_FOLDER = "IgnorePreCache"
local loaded = false

function ProjectileRegistry:Init()
    if loaded then return end
    -- pre-load all projectile configs
    for _, module in ipairs(configs:GetChildren()) do
        if module:GetAttribute(IGNORE_IN__CONFIG_FOLDER) then continue end
        local config = require(module)
        local name = module.Name
        local slotTypes = validator:Exists(config.SlotTypes, "slot type for projectile " .. name)
        local model = validator:Exists(models:FindFirstChild(name), "model for projectile " .. name)
        cache[name] = {
            Config = config,
            Model = model,
            AttachModel = attachModels:FindFirstChild(name)
        }

        for _, type in ipairs(slotTypes) do
            cacheBySlot[type] = cacheBySlot[type] or {}
            table.insert(cacheBySlot[type], name)
        end
    end
end

function ProjectileRegistry:GetProjectile(name)
    if not cache[name] then
        if loaded then
            error("projectile config not found for " .. tostring(name))
        end
        self:Init()
    end
    return cache[name]
end

function ProjectileRegistry:GetProjectilesOfSlotType(slotType)
    if not cacheBySlot[slotType] then
        warn("no valid projectiles found for slot type " .. tostring(slotType))
        return {}
    end
    return cacheBySlot[slotType]
end


return ProjectileRegistry