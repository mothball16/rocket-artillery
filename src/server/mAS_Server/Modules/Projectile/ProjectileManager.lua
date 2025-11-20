local dirServer = require(script.Parent.Parent.Parent.Directory)
local dir = dirServer.Main
local validator = dir.Validator.new(script.Name)
local ProjectileManager = {}
local registry = {}
local ProjectileRegistry = require(dir.Modules.Projectile.ProjectileRegistry)

local function _getContext(player)
    local localReg = registry[player.UserId]
    if not localReg then
        player:Kick("hey!!!!")
    end
    return localReg
end

function ProjectileManager:Register(player, id, args)
    validator:Exists(args.handler, "client handler method of projectile")
    local playerRegistry = _getContext(player)
    if playerRegistry[id] then
        warn("projectile was attempted to be created, but already exists (" .. id .. ")")
        return
    end

    playerRegistry[id] = args
    task.delay(dir.Consts.MAX_PROJECTILE_LIFETIME, function()
        if player and player.Parent and playerRegistry[id] then
            self:Destroy(player, id)
        end
    end)
    dir.NetUtils:FireOtherClients(player, dir.Events.Reliable.OnProjectileCreated, id, args)
end


-- updates projectile and state + last state, then fires upd. back to the other clients
function ProjectileManager:Update(player, id, args)
    local playerRegistry = _getContext(player)
    local state = playerRegistry[id]
    if not state then
        warn("projectile was attempted to be updated, but doesn't exist (" .. id .. ")")
        return
    end
    local updateTime = tick()
    if state[dir.Consts.LAST_UPDATE_FIELD] and updateTime - state[dir.Consts.LAST_UPDATE_FIELD] < dir.Consts.REPLICATION_THROTTLE * 0.5 then
        --warn("remove this warn later - intended behavior")
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
    dir.NetUtils:FireOtherClients(player, dir.Events.Unreliable.OnProjectileUpdated, id, args)
end

-- calls the OnHit method if exists and then calls to destroy
function ProjectileManager:Hit(player, id, args)
    local playerRegistry = _getContext(player)
    local state = playerRegistry[id]
    if not state or not state.projectile then warn("no state/no projectile type in state") return end
    local onHit = validator:Exists(ProjectileRegistry:GetProjectile(state.projectile).Config.OnHit)
    dir.NetUtils:ExecuteOnServer(player, onHit, args)
end



-- "destroys" the object on the server. the object is really just a data container so no phys. cleanup necessary
function ProjectileManager:Destroy(player, id)
    local playerRegistry = _getContext(player)
    local state = playerRegistry[id]
    if not state then
        warn("projectile was attempted to be destroyed, but doesn't exist (" .. id .. ")")
        return
    end
    playerRegistry[id] = nil
    dir.NetUtils:FireOtherClients(player, dir.Events.Reliable.OnProjectileDestroyed, id)
end

function ProjectileManager:Init()
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

    dir.Net:Connect(dir.Events.Reliable.RequestProjectileHit, function(player, id, args)
        self:Hit(player, id, args)
    end)

    dir.Net:ConnectUnreliable(dir.Events.Unreliable.RequestProjectileUpdate, function(player, id, args)
        self:Update(player, id, args)
    end)
end

return ProjectileManager