--#region requires
local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local TwoAxisRotator = require(dir.Modules.Turret.TwoAxisRotator)
local AttachClientController = require(dir.Modules.AttachmentSystem.AttachClientController)
local validator = dir.Validator.new(script.Name)
--#endregion
--[[
this bridges all of the relevant turret systems together
responsibilities so far:
- input for firing
- input for turning
]]

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local TurretController = {}
TurretController.__index = TurretController



function TurretController.new(args, required)
    local self = setmetatable({}, TurretController)
    self.id = dir.NetUtils:GetId(required)
    self.maid = dir.Maid.new()
    self.vehicle = required.Parent
    self.selectedProjectileType = "TOS220Short"
    
    -- component setup
    self.TwoAxisRotator = TwoAxisRotator.new(args.Turret, required)
    self.AttachClientController = AttachClientController.new({}, required)
    
    -- give GC tasks
    self.maid:GiveTask(mouse.Button1Down:Connect(function()
        self:Fire()
    end))
    self.maid:GiveTask(self.TwoAxisRotator)
    self.maid:GiveTask(self.AttachClientController)
    return self
end


function TurretController:Fire()
    local success, slot = self.AttachClientController:FireOff(self.selectedProjectileType)
    if not success then
        validator:Error("Didn't launch successfully from AttachCLientController.")
        return
    end
    dir.Signals.FireProjectile:Fire(slot, self.selectedProjectileType, {self.vehicle, player.Character})
    return true
end

function TurretController:Destroy()
    self.maid:DoCleaning()
end

return TurretController