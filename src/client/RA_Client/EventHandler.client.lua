-- temporary event dump, will eventually refactor

local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local maid = require(dir.Modules.Utility.Maid)
local net, evts = dir.GetNetwork()
-- load order
local TwoAxisRotator = require(dir.Modules.Core.TwoAxisRotator)

net:Connect(evts.OnSeated, function(required)
    print("yo")
    maid:GiveTask(TwoAxisRotator.new({}, required.State, required.RotMotor.Value, required.PitchMotor.Value))
end)

net:Connect(evts.OnUnseated, function(required)
    maid:DoCleaning()
end)

net:ConnectUnreliable(evts.OnTurretWeldsUpdated, function(state)

end)
