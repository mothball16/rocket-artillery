local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local RuS = game:GetService("RunService")
local ProjectileController = require(dir.Modules.Core.ProjectileController)
local RocketController = {}

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
local function _numLerp(a, b, t)
	return a + (b - a) * t
end

function RocketController:CalcSpeed(config, lifetime)
	local burnTime = lifetime - config:Get("burnIn")
	local burnDuration = math.max(config:Get("burnOut") - config:Get("burnIn"),0.01)
	local stage = math.clamp(burnTime / burnDuration, 0, 1)
	local speed = _numLerp(config:Get("initSpeed"), config:Get("maxSpeed"), stage)
	return speed
end
function RocketController:CalcVelo(initLook, speed, drop)
	 return initLook * speed - Vector3.new(0, drop, 0)
end


function RocketController:StepDrop(arc, speed, dt)
	return arc * speed * dt
end

function RocketController:ExecuteOnClient(config, args)
	local config = dir.FallbackConfig.new(config, fallbacks)
	local maid = dir.Maid.new()
	print(config, args)

	local main = args.object.PrimaryPart
	local initLook = (main.CFrame * dir.Helpers:GenInaccuracy(config:Get("initInacc"))).LookVector
	local dropFactor, lifetime, timepasu = 0, 0, 0
	local lastPos = main.Position
	local origPos = main.Position
	local active = true

	main:SetAttribute("Speed", config:Get("initSpeed"))
	local mag,life = self:Simulate(config, initLook)
	print(mag,life, initLook)
	-- handle cleanup/gc
	local function Destroy()
		if not active then return end
		active = false
		ProjectileController.Destroy(main.Parent)
		maid:Destroy()
	end
	task.delay(dir.Consts.MAX_PROJECTILE_LIFETIME, function()
		Destroy()
	end)

	-- main loop
	maid:GiveTask(RuS.Heartbeat:Connect(function(dt)
		if not main.Parent then
			Destroy()
			return
		end
		
		local speed = self:CalcSpeed(config, lifetime)
		main:SetAttribute("Speed", speed)

		-- replication check
		if timepasu > dir.Consts.REPLICATION_THROTTLE then
			ProjectileController.Replicate(main.Parent)
			timepasu = 0
		end

		-- update velo.
		main.AssemblyLinearVelocity = self:CalcVelo(initLook, speed, dropFactor)

		-- check if we hit anything on this frame
		local direction = (main.Position - lastPos).Unit
		local mag = (main.Position - lastPos).Magnitude
		
    	main.CFrame = CFrame.new(main.Position, main.Position + main.AssemblyLinearVelocity.Unit)

		local result = game.Workspace:Raycast(lastPos,direction * mag, args.rayParams)
		if result and result.Instance.Transparency < 1 then
			warn("rocket hit stats", lifetime, (main.Position - origPos).Magnitude)
			ProjectileController.Hit(main.Parent, {
				["pos"] = result.Position,
			})
			Destroy()
		end

		-- (we didnt hit anything so just inc. variables here)
		lastPos = main.Position
		dropFactor += self:StepDrop(config:Get("arc"), speed, dt)

		lifetime += dt
		timepasu += dt

	end))
end


function RocketController:Simulate(args, initLook)
	local lifetime = 0
	-- check if we passed the args or the fallbackConfig (as retrieved from ProjectileController)
	local config = args
	if not config.Get then
		config = dir.FallbackConfig.new(args, fallbacks)
	end
	local dt = 0.03
	local dropFactor = 0
	local pos = Vector3.new()
	while pos.Y >= 0 do
		local speed = self:CalcSpeed(config, lifetime)
		local velo = self:CalcVelo(initLook, speed, dropFactor)
		dropFactor += self:StepDrop(config:Get("arc"), speed, dt)
		pos += velo * dt
		lifetime += dt
	end
	return pos.Magnitude, lifetime
end

return RocketController