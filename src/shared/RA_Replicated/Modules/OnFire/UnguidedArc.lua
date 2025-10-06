local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local RuS = game:GetService("RunService")
local UnguidedArc = {}
UnguidedArc.__index = UnguidedArc


--TODO: FIX MEMORY LEAKS!!!!!!!
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


-- (main)
function UnguidedArc:SetupBodyMovers(config, main)
	local bv = Instance.new("BodyVelocity", main)
	bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
	bv.Velocity = main.CFrame.LookVector * config:Get("initSpeed")
	local bav = Instance.new("BodyAngularVelocity", main)
	bav.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
	bav.AngularVelocity = main.CFrame:VectorToWorldSpace(
		Vector3.new(-math.rad(config:Get("arc")),0,0))

	return bv, bav
end

-- (main)
function UnguidedArc:SetupSpeedLoop(config, main)
	local lifetime = 0
	local connection
	connection = RuS.RenderStepped:Connect(function(dt)
		if not main.Parent then
			connection:Disconnect()
			return
		end
		if lifetime > config:Get("burnOut") then connection:Disconnect() end
		lifetime += dt
		main:SetAttribute("Speed", math.clamp(
			main:GetAttribute("Speed") + (config:Get("accel") * dt),
			config:Get("initSpeed"), config:Get("maxSpeed")))
	end)
end

-- (main, bv, rayParams)
function UnguidedArc:SetupRaycastLoop(config, main, bv, rayParams)
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
			config:Get("onHit")(result.Position)
		end
		lastPos = main.Position
	end)
end

-- (main, rayParams)
function UnguidedArc:Execute(config, main, rayParams)
	config = dir.FallbackConfig.new(config, fallbacks)
	assert(main:IsA("BasePart"), "UnguidedArc fire fail: main should be a BasePart")
	local bv, _ = UnguidedArc:SetupBodyMovers(config, main)
	main:SetAttribute("Speed", config:Get("initSpeed"))

	coroutine.resume(coroutine.create(function()
		task.wait(config:Get("burnIn"))
		if not main or not main.Parent then return end
		UnguidedArc:SetupSpeedLoop(config, main)
	end))
	UnguidedArc:SetupRaycastLoop(config, main, bv, rayParams)
end

-- ()
function UnguidedArc:Destroy()
--	self.maid:Destroy()
end

return UnguidedArc