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


return Rocket
