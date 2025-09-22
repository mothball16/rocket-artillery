local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local maid = require(dir.Modules.Utility.Maid)
local TwoAxisRotator = require(dir.Modules.Core.TwoAxisRotator)
local TurretController = {}
TurretController.__index = TurretController


function TurretController.new(required)
    local self = {}
    self.Rotator = maid:GiveTask(TwoAxisRotator.new(
        {}, 
        required.State, 
        required.RotMotor.Value, 
        required.PitchMotor.Value))
    setmetatable(self, TurretController)
    return self
end

function TurretController:Destroy()
    maid:Destroy()
end

return TurretController