--#region requires
local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local TwoAxisRotator = require(dir.Modules.Turret.TwoAxisRotator)
local AttachClientController = require(dir.Modules.AttachmentSystem.AttachClientController)
local OrientationReader = require(dir.Modules.Instruments.OrientationReader)
local ForwardCamera = require(dir.Modules.Instruments.ForwardCamera)
local Shake = require(dir.Utility.Shake)
local validator = dir.Validator.new(script.Name)
local Signal = require(dir.Utility.Signal)
--#endregion
--[[
this bridges all of the relevant turret systems together
responsibilities so far:
- input for firing
- input for turning
- input for fire control
]]
local CROSSHAIR_DIST = 200

local RuS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = game.Workspace.CurrentCamera
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
    validator:Exists(joystick.CanEnable, "CanEnable function of joystick")
    return ui, joystick
end

function TurretController.new(args, required)
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
    self.joystick = joystick.new(args.Joystick, self.uiHandler:GetRequired())
    -- give GC tasks
    self.maid:GiveTask(self.TwoAxisRotator)
    self.maid:GiveTask(self.AttachClientController)
    self.maid:GiveTask(self.uiHandler)
    self.maid:GiveTask(self.OrientationReader)

    if args.ForwardCamera then
        self.ForwardCamera = ForwardCamera.new(args.ForwardCamera, required)
        self.maid:GiveTask(self.ForwardCamera)
    end

    self:SetupConnections()
    self.uiHandler:SetupStatic({
        title = args.TurretController.turretName
    })

    return self
end

-- TODO: bind this to the new renderstepped, this overrides shake rn
function TurretController:SetupConnections()
    self.maid:GiveTask(RuS.RenderStepped:Connect(function(dt)
        local joystickInput = self.joystick:GetInput()
        self.TwoAxisRotator:SetIntent(joystickInput)
        self.TwoAxisRotator:Update(dt)
        self.uiHandler:Update(dt, {
            stickPos = joystickInput,
            rot = self.TwoAxisRotator:GetRot(),
            orient = self.OrientationReader:GetDirection(),
            pos = self.OrientationReader:GetPos(),
            crosshair = self.OrientationReader:GetForwardPos(CROSSHAIR_DIST),
            inCamera = self.ForwardCamera and self.ForwardCamera.enabled or false,
        })
        if self.ForwardCamera and self.ForwardCamera.enabled then
            self.ForwardCamera:Update()
        end
    end))

    self.maid:GiveTask(UIS.InputBegan:Connect(function(input, chatting)
        if chatting then return end
        local inCam = self.ForwardCamera and self.ForwardCamera.enabled
        if input.KeyCode == dir.Keybinds.MountedFire then
            self:Fire()
        elseif input.KeyCode == dir.Keybinds.SwapSalvo then
            self.localSignals.OnSalvoIntervalModified:Fire(self:SwapSalvo())
        elseif input.KeyCode == dir.Keybinds.SwapInterval then
            self.localSignals.OnTimedIntervalModified:Fire(self:SwapInterval())
        elseif input.KeyCode == dir.Keybinds.RangeFinder then
            --self.localSignals.OnRangeFinderToggled:Fire()
        elseif input.KeyCode == dir.Keybinds.ToggleFCU then
        
        elseif self.ForwardCamera and input.KeyCode == dir.Keybinds.ToggleCamera then
            if inCam then
               self.ForwardCamera:Disable()
            else
                self.ForwardCamera:Enable()
            end
        elseif inCam and input.KeyCode == dir.Keybinds.ZoomIn then

        elseif inCam and input.KeyCode == dir.Keybinds.ZoomOut then
        
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 and self.joystick:CanEnable() then
            self.joystick:Enable()
        end
    end))

    self.maid:GiveTask(UIS.InputEnded:Connect(function(input, chatting)
        if chatting then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.joystick:Disable()
        end
    end))

    -- fire off signals for UI on first update
    self.localSignals.OnSalvoIntervalModified:Fire(self:GetSalvo())
    self.localSignals.OnTimedIntervalModified:Fire(self:GetInterval())
end

local function _shakeCam()
    local priority = Enum.RenderPriority.Last.Value

	local shake = Shake.new()
	shake.FadeInTime = 0
	shake.Frequency = 0.1
	shake.Amplitude = 1
    shake.PositionInfluence = Vector3.new(0,0,0)
	shake.RotationInfluence = Vector3.new(0.01, 0.01, 0.01)

	shake:Start()
	shake:BindToRenderStep(Shake.NextRenderName(), priority, function(pos, rot, isDone)
		camera.CFrame *= CFrame.new(pos) * CFrame.Angles(rot.X, rot.Y, rot.Z)
	end)
end

function TurretController:Fire()
    local success, slot = self.AttachClientController:FireOff(self.selectedProjectileType)
    if not success then
       --validator:Error("Didn't launch successfully from AttachClientController.")
        return
    end
    _shakeCam()
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