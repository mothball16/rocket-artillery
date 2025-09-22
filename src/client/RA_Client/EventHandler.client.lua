-- temporary event dump, will eventually refactor

local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local maid = require(dir.Modules.Utility.Maid)
local net, evts = dir.GetNetwork()
-- load order
local TurretController = require(dir.Modules.Core.TurretController)

net:Connect(evts.OnSeated, function(required)
    maid:GiveTask(TurretController.new({}, required))
end)

net:Connect(evts.OnUnseated, function(required)
    maid:DoCleaning()
end)

net:ConnectUnreliable(evts.OnTurretWeldsUpdated, function(state)

end)
