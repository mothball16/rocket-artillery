local HttpService = game:GetService("HttpService")
local dir = require(script.Parent.Parent.Parent.Directory)
local validator = dir.Validator.new(script.Name)
local rayParams = RaycastParams.new()
local ProjectileRegistry = require(dir.Modules.Core.ProjectileRegistry)
local RequestProjectileCreate = dir.Net:RemoteEvent(dir.Events.Reliable.RequestProjectileCreate)
local RequestProjectileHit = dir.Net:RemoteEvent(dir.Events.Reliable.RequestProjectileHit)
local RequestProjectileDestroy = dir.Net:RemoteEvent(dir.Events.Reliable.RequestProjectileDestroy)
local RequestProjectileUpdate = dir.Net:UnreliableRemoteEvent(dir.Events.Unreliable.RequestProjectileUpdate)
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
---@param args any further arguments relevant to OnFire methods
function ProjectileController.Fire(firePart, ammoName, filterInstances, args)
    --------------------------------------------------------------------
    local data = ProjectileRegistry:GetProjectile(ammoName)
    local onFire = validator:Exists(data.Config["OnFire"], "OnFire prop. of config of projectile " .. ammoName)
    args = args or {}
    --------------------------------------------------------------------

    -- find our projectile and make the physical copy
    local projectile = data.Model:Clone()
    projectile.Parent = game.Workspace
    projectile:SetPrimaryPartCFrame(firePart.CFrame)

    -- setup replication data, send to server
    local id = HttpService:GenerateGUID()
    projectile:SetAttribute(dir.Consts.REPL_ID, id)

    -- [!] this is solely for a client-side copy for client-side effects
    -- the server will never use this for obv. reasons
    projectile:SetAttribute(dir.Consts.AMMO_TYPE, ammoName)
    rayParams.FilterDescendantsInstances = filterInstances
    dir.Helpers:TableCombine(args, {
        ["object"] = projectile,
        ["rayParams"] = rayParams,
    })

    RequestProjectileCreate:FireServer(id, {
        ["cf"] = projectile.PrimaryPart.CFrame,
        ["handler"] = "ReplicateOrientation",
        ["projectile"] = ammoName
    })

    dir.NetUtils:ExecuteOnClient(onFire,args)
end

function ProjectileController.Replicate(object)
    --------------------------------------------------------------------
    local id = object:GetAttribute(dir.Consts.REPL_ID)
    if id == nil then
        warn("no ID registered on projectile, not updating")
        return
    end
    --------------------------------------------------------------------

    RequestProjectileUpdate:FireServer(id, {
        ["cf"] = object.PrimaryPart.CFrame
    })
end

-- calls the hit behavior of the object
function ProjectileController.Hit(object, args)
    --------------------------------------------------------------------
    if not object then validator:Warn("object doesn't exist, aborting") return end
    local id, ammoType = object:GetAttribute(dir.Consts.REPL_ID), object:GetAttribute(dir.Consts.AMMO_TYPE)
    if not id and ammoType then warn("no ID / no ammoType on projectile, not hitting") return end
    local onHit = validator:Exists(ProjectileRegistry:GetProjectile(ammoType).Config.OnHit)
    --------------------------------------------------------------------
    
    dir.Helpers:TableCombine(args, {
        ["object"] = object,
        ["pos"] = args.pos or object.PrimaryPart.Position,
        ["cf"] = object.PrimaryPart.CFrame
    })

    dir.NetUtils:ExecuteOnClient(onHit, args)
    RequestProjectileHit:FireServer(id, args)
end

function ProjectileController.Destroy(object)
    --------------------------------------------------------------------
    if not object then validator:Warn("(destroy) object doesn't exist, aborting") return end
    local id = object:GetAttribute(dir.Consts.REPL_ID)
    if not id then warn("no ID registered on projectile, not destroying") return end
    --------------------------------------------------------------------

    -- prevent new updates and tell the server to drop the id
    object:SetAttribute(dir.Consts.REPL_ID, nil)
    object:Destroy()
    RequestProjectileDestroy:FireServer(id)
end

return ProjectileController