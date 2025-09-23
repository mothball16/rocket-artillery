local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local maid = require(dir.Modules.Utility.Maid)
local signals = require(dir.Signals)
local TwoAxisRotator = require(dir.Modules.Core.TwoAxisRotator)
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local TurretController = {}
TurretController.__index = TurretController


function TurretController.new(rotArgs, required)
    local self = {}
    self.maid = maid.new()
    self.Rotator = self.maid:GiveTask(TwoAxisRotator.new(
        rotArgs, 
        required.State, 
        required.RotMotor.Value, 
        required.PitchMotor.Value))
    setmetatable(self, TurretController)

    mouse.Button1Down:Connect(function()
        signals.FireProjectile:Fire(required.FirePartTest.Value, "TOS220Short")
    end)
    return self
end

function TurretController:Destroy()
    self.maid:Destroy()
end

return TurretController