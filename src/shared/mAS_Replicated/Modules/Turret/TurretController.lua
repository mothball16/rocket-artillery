--#region requires
local dir = require(script.Parent.Parent.Parent.Directory)
local TwoAxisRotator = require(dir.Modules.Turret.TwoAxisRotator)
local AttachClientController = require(dir.Modules.AttachmentSystem.AttachClientController)
local OrientationReader = require(dir.Modules.Instruments.OrientationReader)
local ForwardCamera = require(dir.Modules.Instruments.ForwardCamera)
local RangeSheet = require(dir.Modules.Instruments.RangeSheet)
local Shake = require(dir.Utility.Shake)
local Signal = require(dir.Utility.Signal)
local validator = dir.Validator.new(script.Name)
--#endregion
--[[
this bridges all of the relevant turret systems together
responsibilities so far:
- input for firing
- input for turning
- input for fire control
]]
local CROSSHAIR_DIST = 200
local TURRET_UPD_FUNC = "TurretUpdate"
local RuS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local TurretController = {}
TurretController.__index = TurretController

local fallbacks = {
	salvoIntervals = { 1, 2, 4 },
	timeIntervals = { 0.25, 0.5, 1 },
}

-- plsss plsss plsss bring me back to c# plsss
export type TurretController = {
	id: string,
	maid: typeof(dir.Maid),
	vehicle: Instance,
	selectedProjectileType: string,
	localSignals: {
		OnFire: typeof(Signal),
		OnSalvoIntervalModified: typeof(Signal),
		OnTimedIntervalModified: typeof(Signal),
		OnRangeFinderToggled: typeof(Signal),
	},
	config: {
		salvoIntervals: { number },
		timeIntervals: { number },
		turretName: string,
	},
	state: {
		salvoIndex: number,
		timeIndex: number,
	},

	-- components
	TwoAxisRotator: typeof(TwoAxisRotator),
	AttachClientController: typeof(AttachClientController),
	OrientationReader: typeof(OrientationReader),
	RangeSheet: typeof(RangeSheet),
	ForwardCamera: typeof(ForwardCamera)?,

    -- temp (need to define a contract for this, will do later)
    uiHandler: any,
	joystick: any,

	-- methods
	Destroy: (self: TurretController) -> (),
	DoAction: (self: TurretController, keycode: Enum.KeyCode) -> (),
	DoInput: (self: TurretController, input: Enum.UserInputType) -> (),
	EndAction: (self: TurretController, keycode: Enum.KeyCode) -> (),
	EndInput: (self: TurretController, input: Enum.UserInputType) -> (),
	SetupConnections: (self: TurretController) -> (),
	ShakeCam: (self: TurretController) -> (),
	Fire: (self: TurretController) -> boolean?,
	SwapSalvo: (self: TurretController) -> number,
	GetSalvo: (self: TurretController) -> number,
	SwapInterval: (self: TurretController) -> number,
	GetInterval: (self: TurretController) -> number,
}

--#region init

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

	--TODO: un-hardcode this
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
	self.config = dir.Helpers:TableOverwrite(fallbacks, args.TurretController)
	self.state = {
		salvoIndex = 1,
		timeIndex = 1,
	}

	-- component setup
	self.TwoAxisRotator = TwoAxisRotator.new(args.Turret, required)
	self.AttachClientController = AttachClientController.new({}, required)
	self.OrientationReader = OrientationReader.new(args.OrientationReader, required)

	self.RangeSheet = RangeSheet.new({
		controller = require(dir.Modules.OnFire.RocketController),
		projectile = self.selectedProjectileType,
	})

	self.uiHandler = uiHandler.new(args.UIHandler, required)
	self.joystick = joystick.new(args.Joystick, self.uiHandler:GetRequired())
	-- give GC tasks
	self.maid:GiveTasks(
        self.TwoAxisRotator, self.AttachClientController, self.OrientationReader, self.RangeSheet,
        self.uiHandler, self.joystick)

	if args.ForwardCamera then
		self.ForwardCamera = ForwardCamera.new(args.ForwardCamera, required)
		self.maid:GiveTask(self.ForwardCamera)
	end

	self:SetupConnections()
	self.uiHandler:SetupStatic({
		title = args.TurretController.turretName,
	})

	return self
end

function TurretController.Destroy(self: TurretController)
	self.maid:DoCleaning()
end

function TurretController.SetupConnections(self: TurretController)
	RuS:BindToRenderStep(TURRET_UPD_FUNC, Enum.RenderPriority.Camera.Value - 10, function(dt)
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
	end)

	self.maid:GiveTask(function()
		RuS:UnbindFromRenderStep(TURRET_UPD_FUNC)
	end)

	--TODO: remove dir dependencies. keybinds can be injected instead
	self.maid:GiveTask(UIS.InputBegan:Connect(function(input, chatting)
		if chatting then
			return
		end
		if input.KeyCode then
			self:DoAction(input.KeyCode)
		end
		if input.UserInputType then
			self:DoInput(input.UserInputType)
		end
	end))

	self.maid:GiveTask(UIS.InputEnded:Connect(function(input, chatting)
		if chatting then
			return
		end
		if input.KeyCode then
			self:EndAction(input.KeyCode)
		end
		if input.UserInputType then
			self:EndInput(input.UserInputType)
		end
	end))

	-- fire off signals for UI on first update
	self.localSignals.OnSalvoIntervalModified:Fire(self:GetSalvo())
	self.localSignals.OnTimedIntervalModified:Fire(self:GetInterval())
end

--#endregion

--#region input
function TurretController.DoAction(self: TurretController, keycode: Enum.KeyCode)
	dir.Helpers:Switch(keycode)({
		[dir.Keybinds.MountedFire] = function()
			local numShots = self.config["salvoIntervals"][self.state.salvoIndex]
			for _ = 1, numShots do
				self:Fire()
			end
		end,
		[dir.Keybinds.SwapSalvo] = function()
			self.localSignals.OnSalvoIntervalModified:Fire(self:SwapSalvo())
		end,
		[dir.Keybinds.SwapInterval] = function()
			self.localSignals.OnTimedIntervalModified:Fire(self:SwapInterval())
		end,
		[dir.Keybinds.RangeFinder] = function()
			self.RangeSheet:Toggle()
		end,
		[dir.Keybinds.ToggleCamera] = function()
			local inCam = self.ForwardCamera and self.ForwardCamera.enabled
			if inCam then
				self.ForwardCamera:Disable()
			else
				self.ForwardCamera:Enable()
			end
		end,
		[dir.Keybinds.ZoomIn] = function()

		end,
		[dir.Keybinds.ZoomOut] = function()

		end,
		default = function() end,
	})
end

function TurretController.DoInput(self: TurretController, input: Enum.UserInputType)
	dir.Helpers:Switch(input)({
		[dir.Keybinds.DoAction] = function()
			if self.joystick:CanEnable() then
				self.joystick:Enable()
			end
		end,
		default = function() end,
	})
end

function TurretController.EndAction(self: TurretController, keycode: Enum.KeyCode)
	dir.Helpers:Switch(keycode)({
		default = function() end,
	})
end

function TurretController.EndInput(self: TurretController, input: Enum.UserInputType)
	dir.Helpers:Switch(input)({
		[dir.Keybinds.DoAction] = function()
			self.joystick:Disable()
		end,
		default = function() end,
	})
end
--#endregion

--TODO: check if this causes memory leaks
function TurretController.ShakeCam(self: TurretController)
	local priority = Enum.RenderPriority.Last.Value

	local shake = Shake.new()
	shake.FadeInTime = 0
	shake.Frequency = 0.1
	shake.Amplitude = 1
	shake.PositionInfluence = Vector3.new(0, 0, 0)

	shake.RotationInfluence = Vector3.new(0.01, 0.01, 0.01)

	shake:Start()
	shake:BindToRenderStep(Shake.NextRenderName(), priority, function(pos, rot, isDone)
		camera.CFrame *= CFrame.new(pos) * CFrame.Angles(rot.X, rot.Y, rot.Z)
	end)
end

function TurretController.Fire(self: TurretController)
	local success, slot = self.AttachClientController:FireOff(self.selectedProjectileType)
	if not success then
		--validator:Error("Didn't launch successfully from AttachClientController.")
		return
	end
	self:ShakeCam()
	dir.Signals.FireProjectile:Fire(slot, self.selectedProjectileType, { self.vehicle, player.Character })
	self.localSignals.OnFire:Fire()
	return true
end

function TurretController.SwapSalvo(self: TurretController)
	self.state.salvoIndex = (self.state.salvoIndex % #self.config["salvoIntervals"]) + 1
	return self:GetSalvo()
end

function TurretController.GetSalvo(self: TurretController)
	return self.config["salvoIntervals"][self.state.salvoIndex]
end

function TurretController.SwapInterval(self: TurretController)
	self.state.timeIndex = (self.state.timeIndex % #self.config["timeIntervals"]) + 1
	return self:GetInterval()
end

function TurretController.GetInterval(self: TurretController)
	return self.config["timeIntervals"][self.state.timeIndex]
end

return TurretController