--#region requires
local dirClient = require(script.Parent.Parent.Parent.Directory)
local dir = require(game.ReplicatedStorage.Shared.mAS_Replicated.Directory)
local ProjectileRegistry = require(dir.Modules.Projectile.ProjectileRegistry)
local TwoAxisRotator = require(dir.Modules.Turret.TwoAxisRotator)
local AttachClientController = require(dir.Modules.AttachmentSystem.AttachClientController)
local OrientationReader = require(dir.Modules.Instruments.OrientationReader)
local ForwardCamera = require(dir.Modules.Instruments.ForwardCamera)
local RangeSheet = require(dir.Modules.Instruments.RangeSheet)
local Signal = require(dir.Utility.Signal)
local validator = dir.Validator.new(script.Name)
--#endregion

--[[
this bridges all of the relevant turret systems together for clean functionality
!!this does not handle input!!
!!this is never independently run!!
]]

local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local TurretClientBase = {}
TurretClientBase.__index = TurretClientBase

local fallbacks = {
	salvoIntervals = { 1, 2, 4 },
	timeIntervals = { 0.25, 0.5, 1 },
	rotationIntent = Vector2.new()
}

-- plsss plsss plsss bring me back to c# plsss
export type TurretClientBase = {
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
		rotationIntent: Vector2,
	},

	-- components
	TwoAxisRotator: typeof(TwoAxisRotator),
	AttachClientController: typeof(AttachClientController),
	OrientationReader: typeof(OrientationReader),
	RangeSheet: typeof(RangeSheet),
	ForwardCamera: typeof(ForwardCamera)?,

	-- methods

	Destroy: (self: TurretClientBase) -> (),
	Update: (self: TurretClientBase, dt: number) -> (),
	Fire: (self: TurretClientBase) -> boolean?,
	FireSingle: (self: TurretClientBase) -> boolean?,
	
	SwapSalvo: (self: TurretClientBase) -> number,
	GetSalvo: (self: TurretClientBase) -> number,
	SwapInterval: (self: TurretClientBase) -> number,
	GetInterval: (self: TurretClientBase) -> number,
}

--#region init

local function _checkSetup(required)

end

function TurretClientBase.new(args, required)
	local self = setmetatable({}, TurretClientBase)
	self.id = dir.NetUtils:GetId(required)
	self.maid = dir.Maid.new()
	self.vehicle = required.Parent

	-- core setup
	self.config = dir.Helpers:TableOverwrite(fallbacks, args.TurretBase)
	self.state = {
		salvoIndex = 1,
		timeIndex = 1,
		rotationIntent = Vector2.new(),
		selectedProjectile = nil,
	}

	-- component setup
	self.TwoAxisRotator = TwoAxisRotator.new(args.Turret, required)
	self.AttachClientController = AttachClientController.new({}, required)
	self.OrientationReader = OrientationReader.new(args.OrientationReader, required)

	self.RangeSheet = RangeSheet.new({
		controller = require(dir.Modules.OnFire.RocketController),
		projectile = "TOS220Short",
	})

	-- give GC tasks
	self.maid:GiveTasks(
        self.TwoAxisRotator, self.AttachClientController, self.OrientationReader, 
		self.RangeSheet)

	if args.ForwardCamera then
		self.ForwardCamera = ForwardCamera.new(args.ForwardCamera, required)
		self.maid:GiveTask(self.ForwardCamera)
	end

	-- provide for outside systems
	self.localSignals = {
		OnFire = Signal.new(),
		OnSalvoIntervalModified = Signal.new(),
		OnTimedIntervalModified = Signal.new(),
		OnRangeFinderToggled = Signal.new(),
	}

	-- fire off signals for UI on first update
	self.localSignals.OnSalvoIntervalModified:Fire(self:GetSalvo())
	self.localSignals.OnTimedIntervalModified:Fire(self:GetInterval())

	self.AttachClientController.localSignals.OnRackUpdated:Connect(function()
		-- here we would cycle the selected projetile if necessary
	end)
	return self
end

function TurretClientBase.Destroy(self: TurretClientBase)
	self.maid:DoCleaning()
end
--#endregion


function TurretClientBase.Update(self: TurretClientBase, dt: number)
	self.TwoAxisRotator:SetIntent(self.state.rotationIntent)
	self.TwoAxisRotator:Update(dt)

	if self.ForwardCamera and self.ForwardCamera.enabled then
		self.ForwardCamera:Update()
	end
end

function TurretClientBase.Fire(self: TurretClientBase)
	local numShots = self.config["salvoIntervals"][self.state.salvoIndex]
	for _ = 1, numShots do
		self:FireSingle()
	end
end

function TurretClientBase.FireSingle(self: TurretClientBase)
	-- attempt fire, no fire? return
	local success, slot = self.AttachClientController:FireAt(self.state.selectedProjectile)
	if not success then return end

	-- we did manage to find something to unrack. 
	dir.Signals.FireProjectile:Fire(slot, self.state.selectedProjectile, { self.vehicle, player.Character })
	self.localSignals.OnFire:Fire()
	return true
end


--TODO: consider moving this to TurretPlayerControls - an NPC controller would not be swapping salvos/intervals like this
function TurretClientBase.SwapSalvo(self: TurretClientBase)
	self.state.salvoIndex = (self.state.salvoIndex % #self.config["salvoIntervals"]) + 1
	local newSalvo = self:GetSalvo()
	self.localSignals.OnSalvoIntervalModified:Fire(newSalvo)
	return newSalvo
end

function TurretClientBase.GetSalvo(self: TurretClientBase)
	return self.config["salvoIntervals"][self.state.salvoIndex]
end

function TurretClientBase.SwapInterval(self: TurretClientBase)
	self.state.timeIndex = (self.state.timeIndex % #self.config["timeIntervals"]) + 1
	local newInterval = self:GetInterval()
	self.localSignals.OnTimedIntervalModified:Fire(newInterval)
	return newInterval
end

function TurretClientBase.GetInterval(self: TurretClientBase)
	return self.config["timeIntervals"][self.state.timeIndex]
end

function TurretClientBase.GetRackedProjectiles(self: TurretClientBase)
	return self.AttachClientController.rackedProjectiles
end

return TurretClientBase