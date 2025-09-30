--[[ 
this script is used to boot up objects
for GC safety purposes, only one can be intialized at a time
( to eventually be changed because thats really dumb )
]]

local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local ProjectileController = require(dir.Modules.Core.ProjectileController)
local objectInitializer = require(dir.Modules.Core.ObjectInitializer).new("LocalController")
local owned = {}
-- load order

dir.Net:Connect(dir.Events.OnInitialize, function(required)
    print("yo")
    if owned[required] then return end
    owned[required] = objectInitializer:Execute(required)
end)

dir.Net:Connect(dir.Events.OnDestroy, function(required)
    if owned[required] then
        owned[required].destroy()
        owned[required] = nil
    end
end)

dir.Net:ConnectUnreliable(dir.Events.OnTurretWeldsUpdated, function(state)

end)

dir.Signals.FireProjectile:Connect(ProjectileController.Fire)

