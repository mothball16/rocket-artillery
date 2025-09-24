--[[ 
this script is used to load any modules that will last for the entire
duration of play
]]

local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local maid = require(dir.Utility.Maid).new()
local ProjectileController = require(dir.Modules.Core.ProjectileController)
local TurretController = require(dir.Modules.Components.TurretController)
local signals = require(dir.Signals)

local net, evts = dir.GetNetwork()
-- load order

net:Connect(evts.OnSeated, function(required)
    maid:GiveTask(TurretController.new({
        rotArgs = {}
    }, required))
end)

net:Connect(evts.OnUnseated, function(required)
    maid:DoCleaning()
end)

net:ConnectUnreliable(evts.OnTurretWeldsUpdated, function(state)

end)

signals.FireProjectile:Connect(ProjectileController.Fire)
