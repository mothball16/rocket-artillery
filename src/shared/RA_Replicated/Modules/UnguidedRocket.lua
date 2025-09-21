local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local conf = require(dir.Modules.Utility.FallbackConfig)

local RunService = game:GetService("RunService")

local Events = dir.Shared:WaitForChild("Events")
local AmmoTypes = dir.Shared:WaitForChild("AmmoTypes")
local AmmoConfig = dir.Shared:WaitForChild("AmmoConfig")
local Modules = dir.Shared.Modules

local Rocket = {}
Rocket.__index = Rocket

function numLerp(a, b, t)
	return a + (b - a) * t
end

function Rocket.new(data)
	local self = {}
	local config = require(data["Config"])
	setmetatable(self, Rocket)
	self:Run()
	return self
end

function Rocket:CreateRocket(inacc)
	local rkt = AmmoTypes:FindFirstChild(self.AmmoType):Clone()
	rkt.Parent = game.Workspace:WaitForChild("IgnoreList")
	for i,v in pairs(rkt:GetDescendants()) do
		pcall(function()
			v:SetNetworkOwnership()
		end)
	end
	rkt:SetPrimaryPartCFrame(self.CFrame  * inacc * CFrame.new(0,0,-self.Offset))

	return rkt
end



function Rocket:LaunchFX()
	self.Obj.Main.BurnSFX:Play()
	self.Obj.ThrustEmitter.Fire.Enabled = true
	self.Obj.ThrustEmitter.Smoke.Enabled = true
end


function Rocket:Run()
	local RayParams = RaycastParams.new()
	RayParams.FilterDescendantsInstances = {self.Launcher,self.Obj}
	RayParams.FilterType = Enum.RaycastFilterType.Exclude

	self.Connection = RunService.Heartbeat:Connect(function(dt)
		if self.Obj:FindFirstChild("Main") == nil or self.Lifetime > self.Fuel then print("DISCONNECT!") self.Connection:Disconnect() end
		self.Lifetime += dt
		self.StageTime += dt
		if self.Stage == 1 then
			--do nothing
			if self.Lifetime > 1 then
				self:LaunchFX()
				self.Stage = 2
				self.StageTime = 0
			end --Transition
		elseif self.Stage == 2 then
			local thisPos = self.Obj.Main.RocketAtt.WorldPosition
			local desiredPos = (self.Targ.WorldPosition - self.OrigV) / 5 + Vector3.new(0,self.Ceil,0) + self.OrigV
			if (thisPos - desiredPos).Magnitude < 30 then
				self.Stage = 3 
				self.StageTime = 0
			else
				local StagePhase = math.min(1,math.max(0,self.StageTime/2))
				self:UpdateForces(CFrame.lookAt(thisPos,desiredPos),numLerp(30,150,StagePhase),numLerp(300,600,StagePhase))

			end
		elseif self.Stage == 3 then
			local thisPos = self.Obj.Main.RocketAtt.WorldPosition
			local desiredPos = self.Targ.WorldPosition
			if (thisPos - desiredPos).Magnitude < 50 then
				self.Stage = 4 
				self.StageTime = 0
			else
				local StagePhase = math.min(1,math.max(0,(self.StageTime)/2))
				local StagePhase2 = math.min(1,math.max(0,(self.StageTime)/12))

				self:UpdateForces(CFrame.lookAt(thisPos,desiredPos),numLerp(150,1000,StagePhase2),numLerp(0,600,StagePhase))

			end
		elseif self.Stage == 4 then
			self.LinVel:Destroy()
			self.RotOrient:Destroy()
		end


		if self.OldPos then
			local direction = (self.Obj.Main.Position - self.OldPos).Unit
			local mag = (self.Obj.Main.Position - self.OldPos).Magnitude


			local result = game.Workspace:Raycast(self.OldPos,direction*mag,RayParams)
			if result and result.Instance.Transparency < 1 then
				if self.Stage == 1 then
					self:Abort()
				else
					self.Obj:MoveTo(result.Position)
					self:Explode()
				end

			end
		end
		self.OldPos = self.Obj.Main.Position
	end)
end


function Rocket:Abort()
	if self.Connection then self.Connection:Disconnect() end

	self.Obj.ThrustEmitter:Destroy()
	self.Obj.Main.BurnSFX:Stop()
	for i,v in pairs(self.Obj:GetDescendants()) do
		pcall(function()
			v.CanCollide = true
		end)
	end
	wait(5)
	self:Destroy()
end

function Rocket:Destroy()
	if self.Connection then self.Connection:Disconnect() end
	self.Obj:Destroy()
	self.Targ:Destroy()
end

function Rocket:Explode()
	if self.Connection then self.Connection:Disconnect() end
	self.Obj.Main.Anchored = true
	for i,v in pairs(self.Obj:GetDescendants()) do
		pcall(function()
			v.Transparency = 1
		end)
	end
	self.Obj.ExplosionEmitter.Fire.Enabled = true
	self.Obj.ExplosionEmitter.Smoke.Enabled = true
	self.Obj.Main.ExplodeSFX:Play()
	self.Obj.ThrustEmitter:Destroy()
	self.Obj.Main.BurnSFX:Stop()
	coroutine.resume(coroutine.create(function()
		wait(0.5)
		self.Obj.ExplosionEmitter.Fire.Enabled = false
		self.Obj.ExplosionEmitter.Smoke.Enabled = false
		wait(5)
		self:Destroy()
	end))

	local explosion = Instance.new("Explosion")
	explosion.Position = self.Obj.Main.Position
	explosion.BlastRadius = self.ExplRadius
	explosion.BlastPressure = 50000
	explosion.DestroyJointRadiusPercent = 0
	explosion.Parent = game.Workspace
	explosion.Hit:Connect(function(hit)
		local mag = (hit.Position - self.Obj.Main.Position).Magnitude
		if hit.Name == "Head" and hit.Parent:FindFirstChild("Humanoid") then
			local damageFactor = 1 - mag/self.ExplRadius
			hit.Parent:FindFirstChild("Humanoid"):TakeDamage(self.PDamage * damageFactor)
		end
	end)
end


--[[

coroutine.resume(coroutine.create(function()
	wait(rocketConfig.particleDelay)
	if rocket.Parent then
		for i,v in pairs(rocket:GetChildren()) do
			if v.Name == "Particles" then
				for i,y in pairs(v:GetChildren()) do
					y.Enabled = true
				end
			end
		end
	end
	wait(rocketConfig.burnout)

end))

for i,v in pairs(rocket:GetDescendants()) do
	if v.Name == "Fire" and v.ClassName == "Sound" then
		v:Play()
	end
end
local debrisClone = required:WaitForChild("Debris"):WaitForChild("Template"):Clone()
debrisClone.Parent = required:WaitForChild("Debris")
debrisClone.Enabled = true
delay(0.15,function()
	debrisClone.Enabled = false
end)
game.Debris:AddItem(debrisClone,debrisClone.Lifetime.Max+1)

local bv = Instance.new("BodyVelocity",main)
bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
bv.Velocity = main.CFrame.LookVector * speed
local bav = Instance.new("BodyAngularVelocity",main)
bav.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
bav.AngularVelocity = main.CFrame:vectorToWorldSpace(Vector3.new(-math.rad(rocketConfig.rocketArc),0,0))

coroutine.resume(coroutine.create(function()
	while speed < rocketConfig.rocketMaxSpeed do
		speed += rocketConfig.rocketAccel
		wait(0.1)
	end
end))

local rayparams = RaycastParams.new()
rayparams.FilterDescendantsInstances = {self.Vehicle,game.Workspace.IgnoreList}
rayparams.FilterType = Enum.RaycastFilterType.Exclude
coroutine.resume(coroutine.create(function()

	while rocket.Parent ~= nil and active == true do
		bv.Velocity = (main.CFrame * inaccuracy).LookVector * speed
		oldpos = main.Position
		--main.CFrame  =main.CFrame * CFrame.new(0,0,-rocketConfig.rocketSpeed/60) * CFrame.Angles(math.rad(-rocketConfig.rocketArc/60),0,0)
		--rocket.Main.Orientation = rocket.Main.Orientation + Vector3.new(-config.RocketArc/60*compensation)
		RunService.Heartbeat:Wait()
		if oldpos then


			local direction = (main.Position - oldpos).Unit
			local mag = (main.Position - oldpos).Magnitude


			local result = game.Workspace:Raycast(oldpos,direction*mag,rayparams)
			if result and result.Instance.Transparency < 1 then
				print(math.floor((result.Position-self.AimPoint.Position).Magnitude))
				RA_RS:WaitForChild("Events"):WaitForChild("HitEffect"):FireServer(RA_RS.AmmoConfig:FindFirstChild(config.ammoType),result.Position)
				active = false
				for i,v in pairs(rocket:GetChildren()) do
					if v.Name ~= "Particles" then
						v:Destroy()
					else
						v.Anchored = true
						for i,v in pairs(rocket:FindFirstChild("Particles"):GetChildren()) do
							v.Enabled = false
						end
						game.Debris:AddItem(v,10)
					end
				end
			end

				--[[	local distance = (rocket.Main.Position - oldpos).Magnitude
					local p = Instance.new("Part",game.Workspace)
					p.Anchored = true
					p.CanCollide = false
					p.Material = Enum.Material.Neon
					p.Size = Vector3.new(1, 1, distance)
					p.CFrame = CFrame.lookAt(rocket.Main.Position, oldpos)*CFrame.new(0, 0, -distance/2)
		end
	end
end))]]

return Rocket
