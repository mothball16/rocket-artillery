--#region required
local dir = require(game.ReplicatedStorage.Shared.mAS_Replicated.Directory)
local TurretClientBase = require(script.Parent.TurretClientBase)
local dirClient = require(script.Parent.Parent.Parent.Directory)
local InputSystem = require(dirClient.mOS.Modules.InputSystem)
local validator = dir.Validator.new(script.Name)
local RuS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
--#endregion required
--[[
handles actions for turrets and initializes player-facing controls/components
]]

local fallbacks = {
	keybinds = dir.Keybinds.TurretControls
}

local TurretPlayerControls = {}
TurretPlayerControls.__index = TurretPlayerControls

local JOYSTICK_TOGGLE_THRESHOLD = 0.25
export type TurretPlayerControls = {
	controller: TurretClientBase.TurretClientBase,
}

local function _checkSetup(required)
	local joystick = require(validator:ValueIsOfClass(required:FindFirstChild("Joystick"), "ModuleScript"))
	validator:Exists(joystick.GetInput, "GetInput function of joystick")
	validator:Exists(joystick.CanEnable, "CanEnable function of joystick")
	return joystick
end


function TurretPlayerControls.new(args: {
	controller: TurretClientBase.TurretClientBase,
	keybinds: any,
	joystick: any,

}, required)
    local self = setmetatable({}, TurretPlayerControls)
	local joystick = _checkSetup(required)

	self.config = dir.Helpers:TableOverwrite(fallbacks, args)
	self.controller = args.controller

	self.joystick = joystick.new(args.joystick, nil)
	self.keybinds = self.config.keybinds
	self.timeHoldingJoystick = 0

	-- set up input system
	self.InputSystem = InputSystem.new({
		on = {
			[self.keybinds.MountedFire] = function()
				self.controller:FireSingle()
			end,

			[self.keybinds.SwapSalvo] = function()
				self.controller:SwapSalvo()
			end,

			[self.keybinds.SwapInterval] = function()
				self.controller:SwapInterval()
			end,

			[self.keybinds.RangeFinder] = function()
				self.controller.RangeSheet:ToggleDisplay()
			end,

			[self.keybinds.ToggleCamera] = function()
				local inCam = self.Camera and self.Camera.enabled
				if inCam then
					self.controller.Camera:Disable()
				else
					self.controller.Camera:Enable()
				end
			end,

			[self.keybinds.ZoomIn] = function()

			end,

			[self.keybinds.ZoomOut] = function()

			end,

			[self.keybinds.DoAction] = function()
				if (not self.joystick.enabled) and self.joystick:CanEnable() then
					self.joystick:Enable()
				else
					self.joystick:Disable()
				end
			end,

			[self.keybinds.ToggleHorizontalLock] = function()
				self.joystick.lockedX = not self.joystick.lockedX
				self.joystick.lockedY = false
			end,
			[self.keybinds.ToggleVerticalLock] = function()
				self.joystick.lockedY = not self.joystick.lockedY
				self.joystick.lockedX = false
			end,
		},

		off = {
			[self.keybinds.DoAction] = function()
				-- short-press to toggle
				if self.timeHoldingJoystick < JOYSTICK_TOGGLE_THRESHOLD then
					return
				end
				self.joystick:Disable()
			end
		}
	})

	self.maid = dir.Maid.new()
	self.maid:GiveTasks(
		self.joystick,
		self.InputSystem)
    return self
end

function TurretPlayerControls.Update(self: TurretPlayerControls, dt: number)
	self.controller.state.rotationIntent = self.joystick:GetInput()
	self.timeHoldingJoystick = self.joystick.enabled and (self.timeHoldingJoystick + dt) or 0
end

function TurretPlayerControls:Destroy()
	self.maid:DoCleaning()
end


return TurretPlayerControls