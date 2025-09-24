local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local maid = require(dir.Utility.Maid)
local signals = require(dir.Signals)
local TwoAxisRotator = require(dir.Modules.Components.TwoAxisRotator)
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local TurretController = {}
TurretController.__index = TurretController



function TurretController.new(args, required)
    local self = {}
    self.maid = maid.new()
    self.Rotator = self.maid:GiveTask(
        TwoAxisRotator.new(args.rotArgs, required)
    )

    mouse.Button1Down:Connect(function()
        signals.FireProjectile:Fire(required.FirePartTest.Value, "TOS220Short")
    end)

    setmetatable(self, TurretController)
    return self
end

function TurretController:Destroy()
    self.maid:Destroy()
end

return TurretController