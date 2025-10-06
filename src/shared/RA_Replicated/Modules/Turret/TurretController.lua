--#region requires
local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local TwoAxisRotator = require(dir.Modules.Turret.TwoAxisRotator)
local AttachClientController = require(dir.Modules.AttachmentSystem.AttachClientController)
local MouseBasedJoystick = require(dir.Modules.Joystick.MouseBasedJoystick)
local validator = dir.Validator.new(script.Name)
--#endregion
--[[
this bridges all of the relevant turret systems together
responsibilities so far:
- input for firing
- input for turning
]]
local RuS = game:GetService("RunService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local TurretController = {}
TurretController.__index = TurretController

local function _checkSetup(required)
    local ui = require(validator:ValueIsOfClass(required:FindFirstChild("UIHandler"), "ModuleScript"))
    validator:Exists(ui.new, "initializer of UI handler")
    local joystick = require(validator:ValueIsOfClass(required:FindFirstChild("Joystick"), "ModuleScript"))
    validator:Exists(joystick.GetInput, "GetInput function of joystick")
    return ui, joystick
end

function TurretController.new(args, required)
    local uiHandler, joystick = _checkSetup(required)
    local self = setmetatable({}, TurretController)
    self.id = dir.NetUtils:GetId(required)
    self.maid = dir.Maid.new()
    self.vehicle = required.Parent
    self.selectedProjectileType = "TOS220Short"
    
    -- component setup
    self.TwoAxisRotator = TwoAxisRotator.new(args.Turret, required)
    self.AttachClientController = AttachClientController.new({}, required)
    self.uiHandler = uiHandler.new(args.Turret, required)
    self.joystick = joystick.new(args.Turret, required)
    -- give GC tasks
    self.maid:GiveTask(self.TwoAxisRotator)
    self.maid:GiveTask(self.AttachClientController)

    self.maid:GiveTask(self.uiHandler)
    self:SetupConnections()
    return self
end


function TurretController:Fire()
    local success, slot = self.AttachClientController:FireOff(self.selectedProjectileType)
    if not success then
       --validator:Error("Didn't launch successfully from AttachClientController.")
        return
    end
    dir.Signals.FireProjectile:Fire(slot, self.selectedProjectileType, {self.vehicle, player.Character})
    return true
end

function TurretController:SetupConnections()
    self.maid:GiveTask(RuS.RenderStepped:Connect(function(dt)
        self.TwoAxisRotator:SetIntent(self.joystick:GetInput())
        self.TwoAxisRotator:Update(dt)
    end))
    self.maid:GiveTask(mouse.Button1Down:Connect(function()
        self:Fire()
    end))
end

function TurretController:Destroy()
    self.maid:DoCleaning()
end

return TurretController