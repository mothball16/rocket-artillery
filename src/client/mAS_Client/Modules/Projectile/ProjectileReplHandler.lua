--#region required
local dirClient = require(script.Parent.Parent.Parent.Directory)
local dir = dirClient.Main
local validator = dir.Validator.new(script.Name)
local ProjectileRegistry = require(dir.Modules.Projectile.ProjectileRegistry)
--#endregion required
--[[
dispatches replication events to handlers and invalidates bad requests
the player check for validating requests is irrelevant here, GUIDs should be unique
so they can just be stored in a one depth table
]]

local ProjectileReplHandler = {}
local handlers = script.Parent.Handlers
local registry = {}
local handlerLookup = {
    ["ReplicateOrientation"] = require(handlers.ReplicateOrientationHandler)
}

function ProjectileReplHandler:HandleRegister(id, args)
    if registry[id] then warn("obj. id " .. id .. " already registered") end
    local handler = handlerLookup[args.handler]
    if not handler then warn("handler not found") return end
    local data = ProjectileRegistry:GetProjectile(args.projectile)
    if not data then warn("projectile model not found") return end
    local obj = handler:Create(data.Model, args)
    registry[id] = args
    registry[id].object = obj
    for _, v in pairs(data.Config.OnFire) do
        if v.replicateAcrossClients then
            dir.NetUtils:ExecuteOnClient({v}, args)
        end
    end

    task.delay(dir.Consts.MAX_PROJECTILE_LIFETIME, function()
        if registry[id] then
            self:Destroy(id)
        end
    end)
end

function ProjectileReplHandler:HandleUpdate(id, state)
    local registryEntry = registry[id]
    if not registryEntry then warn("no registry entry (update)") return end
    local handler = handlerLookup[registryEntry.handler]
    for k, v in pairs(state) do
        registryEntry[k] = v
    end
    local success = handler:Update(registryEntry.object, registryEntry)
    if not success then self:HandleDestroy(id) end
end

function ProjectileReplHandler:HandleDestroy(id)
    local registryEntry = registry[id]
    if not registryEntry then warn("no registry entry (destroy)") return end
    local handler = handlerLookup[registryEntry.handler]
    handler:Destroy(registryEntry.object)
    registry[id] = nil
end

function ProjectileReplHandler:Init()
    dir.Net:Connect(dir.Events.Reliable.OnProjectileCreated, function(id, args)
        self:HandleRegister(id, args)
    end)
    dir.Net:ConnectUnreliable(dir.Events.Unreliable.OnProjectileUpdated, function(id, state)
        self:HandleUpdate(id, state)
    end)
    dir.Net:Connect(dir.Events.Reliable.OnProjectileDestroyed, function(id)
        self:HandleDestroy(id)
    end)
end

function ProjectileReplHandler:PrintForDebugging()
    print("--- projectile repl client handler dump---")
    print("objects in registry: " .. tostring(#registry))
    print("registry: " .. tostring(registry))
    print("------------------------------------------")
end

return ProjectileReplHandler