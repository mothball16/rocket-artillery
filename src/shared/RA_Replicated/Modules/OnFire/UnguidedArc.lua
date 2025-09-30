local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local RuS = game:GetService("RunService")
local UnguidedArc = {}
UnguidedArc.__index = UnguidedArc


-- notes for future refactoring - i'm not too sure about putting the callback here
-- maybe attach a bindable to report back that our arc has finished instead, or just poll (easier)?
-- TODO: this would probably do better as a use and dump instead of making a weird set of coroutines

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

-- (args, callback)
function UnguidedArc.new(args, callback)
	local self = {}
	self.config = dir.FallbackConfig.new(args, fallbacks)
	self.maid = dir.Maid.new()
	self.onHit = callback
	setmetatable(self, UnguidedArc)
	return self
end

-- (main)
function UnguidedArc:SetupBodyMovers(main)
	local bv = Instance.new("BodyVelocity", main)
	bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
	bv.Velocity = main.CFrame.LookVector * self.config:Get("initSpeed")
	local bav = Instance.new("BodyAngularVelocity", main)
	bav.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
	bav.AngularVelocity = main.CFrame:VectorToWorldSpace(
		Vector3.new(-math.rad(self.config:Get("arc")),0,0))

	return bv, bav
end

-- (main)
function UnguidedArc:SetupSpeedLoop(main)
	local lifetime = 0
	local connection
	connection = RuS.RenderStepped:Connect(function(dt)
		if not main.Parent then
			connection:Disconnect()
			return
		end
		if lifetime > self.config:Get("burnOut") then connection:Disconnect() end
		lifetime += dt

		main:SetAttribute("Speed", math.clamp(
			main:GetAttribute("Speed") + (self.config:Get("accel") * dt),
			self.config:Get("initSpeed"), self.config:Get("maxSpeed")))
	end)
end

-- (main, bv, rayParams)
function UnguidedArc:SetupRaycastLoop(main, bv, rayParams)
	local lastPos = main.Position
	local timepasu = 0
	local connection
	connection = RuS.RenderStepped:Connect(function(dt)
		if not main.Parent then
			connection:Disconnect()
			return
		end
		timepasu += dt
		if timepasu > dir.Consts.REPLICATION_THROTTLE then
			
		end

		bv.Velocity = (main.CFrame).LookVector * main:GetAttribute("Speed")

		local direction = (main.Position - lastPos).Unit
		local mag = (main.Position - lastPos).Magnitude

		local result = game.Workspace:Raycast(lastPos,direction * mag, rayParams)
		if result and result.Instance.Transparency < 1 then
			connection:Disconnect()
			self.config.onHit(result.Position)
		end
		lastPos = main.Position
	end)
end

-- (main, rayParams)
function UnguidedArc:Execute(main, rayParams)
	assert(main:IsA("BasePart"), "UnguidedArc fire fail: main should be a BasePart")
	local bv, _ = self:SetupBodyMovers(main)
	main:SetAttribute("Speed", self.config:Get("initSpeed"))

	coroutine.resume(coroutine.create(function()
		task.wait(self.config:Get("burnIn"))
		if not main or not main.Parent then return end
		self:SetupSpeedLoop(main)
	end))
	self:SetupRaycastLoop(main, bv, rayParams)
end

-- ()
function UnguidedArc:Destroy()
	self.maid:Destroy()
end

return UnguidedArc