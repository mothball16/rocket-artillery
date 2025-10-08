--#region requires
local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local TwoAxisRotator = require(dir.Modules.Turret.TwoAxisRotator)
local AttachClientController = require(dir.Modules.AttachmentSystem.AttachClientController)
local MouseBasedJoystick = require(dir.Modules.Joystick.MouseBasedJoystick)
local OrientationReader = require(dir.Modules.Instruments.OrientationReader)
local validator = dir.Validator.new(script.Name)
local Signal = require(dir.Utility.Signal)
--#endregion
--[[
this bridges all of the relevant turret systems together
responsibilities so far:
- input for firing
- input for turning
]]
local RuS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local TurretController = {}
TurretController.__index = TurretController

local fallbacks = {
    salvoIntervals = {1, 2, 4};
    timeIntervals = {0.25, 0.5, 1};
    FCUAttached = false;
}



local function _checkSetup(required)
    local ui = require(validator:ValueIsOfClass(required:FindFirstChild("UIHandler"), "ModuleScript"))
    validator:Exists(ui.new, "constructor of UI handler")
    validator:Exists(ui.Update, "update of UI handler")
    validator:Exists(ui.SetupStatic, "static label initializer of UI handler")
    local joystick = require(validator:ValueIsOfClass(required:FindFirstChild("Joystick"), "ModuleScript"))
    validator:Exists(joystick.GetInput, "GetInput function of joystick")
    return ui, joystick
end

function TurretController.new(args, required)
    print("my boy")
    local uiHandler, joystick = _checkSetup(required)
    local self = setmetatable({}, TurretController)
    self.id = dir.NetUtils:GetId(required)
    self.maid = dir.Maid.new()
    self.vehicle = required.Parent
    self.selectedProjectileType = "TOS220Short"
    
    -- (connect UI)
    self.localSignals = {
        OnFire = Signal.new(),
        OnSalvoIntervalModified = Signal.new(),
        OnTimedIntervalModified = Signal.new(),
        OnRangeFinderToggled = Signal.new(),
    }
    args.UIHandler["signals"] = self.localSignals

    -- core setup
    self.config = dir.FallbackConfig.new(args.TurretController, fallbacks)
    self.state = {
        salvoIndex = 1,
        timeIndex = 1,
    }

    -- component setup
    self.TwoAxisRotator = TwoAxisRotator.new(args.Turret, required)
    self.AttachClientController = AttachClientController.new({}, required)
    self.OrientationReader = OrientationReader.new(args.OrientationReader, required)

    self.uiHandler = uiHandler.new(args.UIHandler, required)
    self.joystick = joystick.new(args.Joystick, required)
    -- give GC tasks
    self.maid:GiveTask(self.TwoAxisRotator)
    self.maid:GiveTask(self.AttachClientController)
    self.maid:GiveTask(self.uiHandler)
    self.maid:GiveTask(self.OrientationReader)
    self:SetupConnections()
    self.uiHandler:SetupStatic({
        title = args.TurretController.turretName
    })

    return self
end


function TurretController:SetupConnections()
    self.maid:GiveTask(RuS.RenderStepped:Connect(function(dt)
        local joystickInput = self.joystick:GetInput()
        self.TwoAxisRotator:SetIntent(joystickInput)
        self.TwoAxisRotator:Update(dt)
        self.uiHandler:Update(dt, {
            stickPos = joystickInput,
            rot = self.TwoAxisRotator:GetRot(),
            orient = self.OrientationReader:GetDirection(),
            height = self.OrientationReader:GetAltitude(),
        })
    end))

    self.maid:GiveTask(UIS.InputBegan:Connect(function(input, chatting)
        if input.KeyCode == dir.Keybinds.MountedFire then
            self:Fire()
        elseif input.KeyCode == dir.Keybinds.SwapSalvo then
            self.localSignals.OnSalvoIntervalModified:Fire(self:SwapSalvo())
        elseif input.KeyCode == dir.Keybinds.SwapInterval then
            self.localSignals.OnTimedIntervalModified:Fire(self:SwapInterval())
        elseif input.KeyCode == dir.Keybinds.RangeFinder then
            --self.localSignals.OnRangeFinderToggled:Fire()
        elseif input.KeyCode == dir.Keybinds.ToggleFCU then
            
        end
    end))

    -- fire off signals for UI on first update
    self.localSignals.OnSalvoIntervalModified:Fire(self:GetSalvo())
    self.localSignals.OnTimedIntervalModified:Fire(self:GetInterval())
end


function TurretController:Fire()
    local success, slot = self.AttachClientController:FireOff(self.selectedProjectileType)
    if not success then
       --validator:Error("Didn't launch successfully from AttachClientController.")
        return
    end
    dir.Signals.FireProjectile:Fire(slot, self.selectedProjectileType, {self.vehicle, player.Character})
    self.localSignals.OnFire:Fire()
    return true
end

--#region salvo/interval control
function TurretController:SwapSalvo()
    self.state.salvoIndex = (self.state.salvoIndex % #self.config:Get("salvoIntervals")) + 1
    return self:GetSalvo()
end

function TurretController:GetSalvo()
    return self.config:Get("salvoIntervals")[self.state.salvoIndex]
end

function TurretController:SwapInterval()
    self.state.timeIndex = (self.state.timeIndex % #self.config:Get("timeIntervals")) + 1
    return self:GetInterval()
end

function TurretController:GetInterval()
    return self.config:Get("timeIntervals")[self.state.timeIndex]
end
--#endregion

function TurretController:Destroy()
    self.maid:DoCleaning()
end



return TurretController