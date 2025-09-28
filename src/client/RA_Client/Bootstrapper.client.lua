--[[ 
this script is used to load any modules that will last for the entire
duration of play
]]

local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local ProjectileController = require(dir.Modules.Core.ProjectileController)
local TurretController = require(dir.Modules.Turret.TurretController)
local ObjRegistry = require(dir.Modules.Core.ObjRegistry)
local owned = nil
-- load order

dir.Net:Connect(dir.Events.OnSeated, function(required)
    local turret = TurretController.new({rotArgs = {}}, required)
    owned = {
        object = ObjRegistry:Register(turret, required),
        destroy = function() ObjRegistry:Deregister(required) end,
    }
end)

dir.Net:Connect(dir.Events.OnUnseated, function(required)
    if owned then
        owned.destroy()
    end
end)

dir.Net:ConnectUnreliable(dir.Events.OnTurretWeldsUpdated, function(state)

end)

dir.Signals.FireProjectile:Connect(ProjectileController.Fire)
