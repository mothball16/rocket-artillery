local dir = require(game.ReplicatedStorage.Shared.RA_Directory)

local TwoAxisRotator = require(dir.Modules.Components.TwoAxisRotator)
local AttachSelector = require(dir.Modules.AttachmentSystem.AttachSelector)
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local TurretController = {}
TurretController.__index = TurretController



-- (args, required)
function TurretController.new(args, required)
    local self = setmetatable({}, TurretController)
    self.maid = dir.Maid.new()
    self.Rotator = self.maid:GiveTask(TwoAxisRotator.new(args.rotArgs, required))
    self.AttachSelector = self.maid:GiveTask(AttachSelector.new({}, required))

    self.maid:GiveTask(mouse.Button1Down:Connect(function()
        dir.Signals.FireProjectile:Fire(required.FirePartTest.Value, "TOS220Short")
    end))

    return self
end

-- ()
function TurretController:Destroy()
    self.maid:Destroy()
end

return TurretController