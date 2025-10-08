--[[ 
this script is used to boot up objects
]]

local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local ProjectileController = require(dir.Modules.Core.ProjectileController)
local objectInitializer = require(dir.Modules.ObjectManagement.ObjectInitializer).new("LocalController")
local owned = {}
-- load order


return function() 
    dir.Net:ConnectUnreliable(dir.Events.Unreliable.OnTurretWeldsUpdated, function(state)

    end)

    dir.Signals.FireProjectile:Connect(ProjectileController.Fire)
end