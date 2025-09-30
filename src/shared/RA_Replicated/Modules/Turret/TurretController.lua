local dir = require(game.ReplicatedStorage.Shared.RA_Directory)

local TwoAxisRotator = require(dir.Modules.Turret.TwoAxisRotator)
local AttachSelector = require(dir.Modules.AttachmentSystem.AttachSelector)
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local TurretController = {}
TurretController.__index = TurretController



function TurretController.new(args, required)
    local self = setmetatable({}, TurretController)
    self.maid = dir.Maid.new()
    self.Rotator = TwoAxisRotator.new(args.Turret, required)
    self.AttachSelector = AttachSelector.new(args.AttachSelector, required)
    self.maid:GiveTask(mouse.Button1Down:Connect(function()
        local nextSlot = self.AttachSelector:FindNextFull()
        if nextSlot then
            print("yoyo")
        end
        dir.Signals.FireProjectile:Fire(required.FirePartTest.Value, "TOS220Short")
    end))
    self.maid:GiveTask(self.Rotator)
    self.maid:GiveTask(self.AttachSelector)
    return self
end

-- ()
function TurretController:Destroy()
    self.maid:Destroy()
end

return TurretController