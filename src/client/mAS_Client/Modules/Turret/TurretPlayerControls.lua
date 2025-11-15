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
handles actions for turrets & updates UI
]]

local fallbacks = {
	keybinds = dir.Keybinds.TurretControls
}

local TurretPlayerControls = {}
TurretPlayerControls.__index = TurretPlayerControls
local CROSSHAIR_DIST = 200

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
	Joystick: any,

}, required)
    local self = setmetatable({}, TurretPlayerControls)
	local joystick = _checkSetup(required)

	self.config = dir.Helpers:TableOverwrite(fallbacks, args)
	self.controller = args.controller
	self.joystick = joystick.new(args.Joystick, nil)
	self.keybinds = self.config.keybinds


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
				self.controller.RangeSheet:Toggle()
			end,

			[self.keybinds.ToggleCamera] = function()
				local inCam = self.ForwardCamera and self.ForwardCamera.enabled
				if inCam then
					self.controller.ForwardCamera:Disable()
				else
					self.controller.ForwardCamera:Enable()
				end
			end,

			[self.keybinds.ZoomIn] = function()

			end,

			[self.keybinds.ZoomOut] = function()

			end,

			[self.keybinds.DoAction] = function()
				if self.joystick:CanEnable() then
					self.joystick:Enable()
				end
			end,
		},

		off = {
			[self.keybinds.DoAction] = function()
				self.joystick:Disable()
			end
		}
	})

	self.maid = dir.Maid.new()
	self.maid:GiveTasks(
		self.uiHandler,
		self.joystick,
		self.InputSystem)
    return self
end

function TurretPlayerControls.Update(self: TurretPlayerControls, dt: number)
	self.controller.state.rotationIntent = self.joystick:GetInput()
end

function TurretPlayerControls:Destroy()
	self.maid:DoCleaning()
end


return TurretPlayerControls