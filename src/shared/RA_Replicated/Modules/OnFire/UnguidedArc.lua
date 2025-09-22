local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local conf = require(dir.Modules.Utility.FallbackConfig)
local maid = require(dir.Modules.Utility.Maid)
local RuS = game:GetService("RunService")
local UnguidedArc = {}
UnguidedArc.__index = UnguidedArc


-- notes for future refactoring - i'm not too sure about putting the callback here
-- maybe attach a bindable to report back that our arc has finished instead, or just poll (easier)?

local fallbacks = {
	["initSpeed"] = 30;
	["maxSpeed"] = 600;
	["accel"] = 800;

	["burnIn"] = 0;
	["burnOut"] = 1;

	["arc"] = 10;
	["initInacc"] = 1.5;
	["flyInacc"] = 0.1;

	["despawn"] = 10;
}

function UnguidedArc.new(args, callback)
	local self = {}
	self.config = conf.new(args, fallbacks)
	self.speed = 0
	self.lifetime = 0
	self.maid = maid.new()
	self.onFinish = callback
	setmetatable(self, UnguidedArc)
	return self
end

function UnguidedArc:SetupBodyMovers()
	local bv = Instance.new("BodyVelocity", self.main)
	bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
	bv.Velocity = self.main.CFrame.LookVector * self.speed
	local bav = Instance.new("BodyAngularVelocity",self.main)
	bav.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
	bav.AngularVelocity = self.main.CFrame:VectorToWorldSpace(
		Vector3.new(-math.rad(self.config.Get("arc")),0,0))

	return bv, bav
end

function UnguidedArc:SetupSpeedLoop()
	local lifetime = 0
	self.speed = self.config:Get("initSpeed")
	self.maid:GiveTask(RuS.RenderStepped:Connect(function(dt)
		-- could just dispose of this individually, but i cant find the maid api : ( negligible impact anyways
		if lifetime > self.config.Get("burnOut") then return end
		lifetime += dt
		self.speed = math.clamp(
			self.speed + (self.config:Get("accel") * dt), 
			self.config:Get("initSpeed"), self.config:Get("maxSpeed"))
	end))
end

function UnguidedArc:SetupRaycastLoop(bv, main, rayParams)
	local lastPos = main.Position
	self.maid:GiveTask(RuS.RenderStepped:Connect(function(dt)
		
		bv.Velocity = (self.main.CFrame).LookVector * self.speed

		local direction = (main.Position - lastPos).Unit
		local mag = (main.Position - lastPos).Magnitude


		local result = game.Workspace:Raycast(lastPos,direction * mag, rayParams)
		if result and result.Instance.Transparency < 1 then
			self:Destroy()
		end
		lastPos = main.Position
	end))
end

function UnguidedArc:Fire(main, rayParams)
	assert(main:IsA("BasePart"), "UnguidedArc fire fail: main should be a BasePart")
	assert(rayParams:IsA("RaycastParams"), "UnguidedArc fire fail: rayParams should be a RaycastParams")
	local bv, _ = self:SetupBodyMovers()
	coroutine.resume(coroutine.create(function()
		task.wait(self.config:Get("burnIn"))
		if not self or not self.Parent then return end
		self:SetupSpeedLoop(bv)
	end))
	self:SetupRaycastLoop(bv, main, rayParams)
end

function UnguidedArc:Destroy()
	self.onFinish()
	self.maid:Destroy()
end

return UnguidedArc