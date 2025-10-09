local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local validator = dir.Validator.new(script.Name)
local ProjectileManager = {}
local registry = {}
local LAST_UPDATE = "mAS_lastUpdate"
local MAX_PROJECTILE_LIFETIME = 60

local function _getContext(player)
    local localReg = registry[player.UserId]
    if not localReg then
        player:Kick("hey!!!!")
    end
    return localReg
end

function ProjectileManager:Register(player, id, args)
    validator:Exists(args.handler, "client handler method of projectile")
    local reg = _getContext(player)
    if reg[id] then
        warn("projectile was attempted to be created, but already exists (" .. id .. ")")
        return
    end

    reg[id] = args
    task.delay(MAX_PROJECTILE_LIFETIME, function()
        if player and player.Parent and reg[id] then
            self:Destroy(player, id)
        end
    end)
    dir.NetUtils:FireOtherClients(player, dir.Events.Reliable.OnProjectileCreated, args)
end

function ProjectileManager:Update(player, id, args)
    local reg = _getContext(player)
    local state = reg[id]
    if not state then
        warn("projectile was attempted to be updated, but doesn't exist (" .. id .. ")")
        return
    end
    local updateTime = tick()
    if state[LAST_UPDATE] and updateTime - state[LAST_UPDATE] < dir.Consts.REPLICATION_THROTTLE then
        warn("remove this warn later - intended behavior")
        return
    end
    state[LAST_UPDATE] = updateTime
    for k, v in pairs(args) do
        state[k] = v
    end
    dir.NetUtils:FireOtherClients(player, dir.Events.Unreliable.OnProjectileUpdated, id, args)
end

function ProjectileManager:Destroy(player, id)
    local reg = _getContext(player)
    local state = reg[id]
    if not state then
        warn("projectile was attempted to be destroyed, but doesn't exist (" .. id .. ")")
        return
    end
    reg[id] = nil
    dir.NetUtils:FireOtherClients(player, dir.Events.Reliable.OnProjectileDestroyed, id)
end

function ProjectileManager:SetupConnections()
    game.Players.PlayerAdded:Connect(function(player)
        registry[player.UserId] = {}
    end)

    game.Players.PlayerRemoving:Connect(function(player)
        registry[player.UserId] = nil
    end)

    dir.Net:RemoteEvent(dir.Events.Reliable.RequestProjectileCreate)
        :Connect(function(player, id, args)
        self:Register(player, id, args)
    end)

    dir.Net:RemoteEvent(dir.Events.Reliable.RequestProjectileDestroy)
        :Connect(function(player, id)
        self:Destroy(player, id)
    end)

    dir.Net:UnreliableRemoteEvent(dir.Events.Unreliable.RequestProjectileUpdate)
        :Connect(function(player, id, args)
        self:Update(player, id, args)
    end)
end

return ProjectileManager