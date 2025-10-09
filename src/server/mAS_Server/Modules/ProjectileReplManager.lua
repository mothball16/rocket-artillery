local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local validator = dir.Validator.new(script.Name)
local ProjectileReplManager = {}
local registry = {}
local OnProjectileCreated = dir.Net:RemoteEvent(dir.Events.Reliable.OnProjectileCreated)
local OnProjectileUpdated = dir.Net:UnreliableRemoteEvent(dir.Events.Unreliable.OnProjectileUpdated)
local OnProjectileDestroyed = dir.Net:RemoteEvent(dir.Events.Reliable.OnProjectileDestroyed)

local function _getContext(player)
    local localReg = registry[player.UserId]
    if not localReg then
        player:Kick("hey!!!!")
    end
    return localReg
end

function ProjectileReplManager:Register(player, id, args)
    validator:Exists(args.handler, "client handler method of projectile")
    local reg = _getContext(player)
    if reg[id] then
        warn("projectile was attempted to be created, but already exists (" .. id .. ")")
        return
    end

    reg[id] = args
    task.delay(dir.Consts.MAX_PROJECTILE_LIFETIME, function()
        if player and player.Parent and reg[id] then
            self:Destroy(player, id)
        end
    end)
    dir.NetUtils:FireOtherClients(player, OnProjectileCreated, id, args)
end

function ProjectileReplManager:Update(player, id, args)
    local reg = _getContext(player)
    local state = reg[id]
    if not state then
        warn("projectile was attempted to be updated, but doesn't exist (" .. id .. ")")
        return
    end
    local updateTime = tick()
    if state[dir.Consts.LAST_UPDATE_FIELD] and updateTime - state[dir.Consts.LAST_UPDATE_FIELD] < dir.Consts.REPLICATION_THROTTLE * 0.5 then
        warn("remove this warn later - intended behavior")
        return
    end
    args[dir.Consts.LAST_UPDATE_FIELD] = updateTime
    local lastArgs = {}
    for k, v in pairs(args) do
        if state[k] then
            lastArgs[k .. "_last"] = state[k]
        end
        state[k] = v
    end

    state[dir.Consts.LAST_UPDATE_FIELD] = updateTime
    dir.Helpers:TableCombine(args, lastArgs)
    dir.NetUtils:FireOtherClients(player, OnProjectileUpdated, id, args)
end

function ProjectileReplManager:Destroy(player, id)
    local reg = _getContext(player)
    local state = reg[id]
    if not state then

        warn("projectile was attempted to be destroyed, but doesn't exist (" .. id .. ")")
        return
    end
    reg[id] = nil
    dir.NetUtils:FireOtherClients(player, OnProjectileDestroyed, id)
end

function ProjectileReplManager:SetupConnections()
    game.Players.PlayerAdded:Connect(function(player)
        registry[player.UserId] = {}
    end)

    game.Players.PlayerRemoving:Connect(function(player)
        registry[player.UserId] = nil
    end)

    dir.Net:Connect(dir.Events.Reliable.RequestProjectileCreate, function(player, id, args)
        self:Register(player, id, args)
    end)

    dir.Net:Connect(dir.Events.Reliable.RequestProjectileDestroy, function(player, id)
        self:Destroy(player, id)
    end)

    dir.Net:ConnectUnreliable(dir.Events.Unreliable.RequestProjectileUpdate, function(player, id, args)
        self:Update(player, id, args)
    end)
end

return function() ProjectileReplManager:SetupConnections() end