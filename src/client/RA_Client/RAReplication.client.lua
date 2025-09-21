local resources = game.ReplicatedStorage:WaitForChild("RARequired"):WaitForChild("Events")
local RArequired = game.ReplicatedStorage:WaitForChild("RARequired")
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local camera = game.Workspace.CurrentCamera

resources.UpdateWelds.OnClientEvent:Connect(function(required,yaw,pitch)
	if required:FindFirstChild("Base") and required:FindFirstChild("Base"):FindFirstChild("Pivot") then
		required:FindFirstChild("Base"):FindFirstChild("Pivot").C1 = yaw
	end
	if required:FindFirstChild("Elevation") and required:FindFirstChild("Elevation"):FindFirstChild("Pivot") then
		required:FindFirstChild("Elevation"):FindFirstChild("Pivot").C1 = pitch
	end
end)

resources.ReplicateRocket.OnClientEvent:Connect(function(baseRocket,config,inaccuracy)

	for i,v in pairs(baseRocket:GetChildren()) do
		if v.Name == "Backblast" then
			for i,y in pairs(v:GetChildren()) do
				y.Enabled = true
				delay(0.15,function()
					y.Enabled = false
				end)
			end
		end
	end
	local rocket = RArequired.AmmoTypes:FindFirstChild(config.ammoType):Clone()
	local main = rocket:WaitForChild("Main")
	local rocketConfig = require(RArequired.AmmoConfig:FindFirstChild(config.ammoType))
	local speed = rocketConfig.rocketSpeed
	rocket.Parent = game.Workspace:WaitForChild("IgnoreList")
	rocket:SetPrimaryPartCFrame(baseRocket:FindFirstChild("FirePart").CFrame  * inaccuracy * CFrame.new(0,0,-config.offset))

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
	local bv = Instance.new("BodyVelocity",main)
	bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
	bv.Velocity = main.CFrame.LookVector * speed
	local bav = Instance.new("BodyAngularVelocity",main)
	bav.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
	bav.AngularVelocity = main.CFrame:vectorToWorldSpace(Vector3.new(-math.rad(rocketConfig.rocketArc),0,0))

	coroutine.resume(coroutine.create(function()
		while speed < rocketConfig.rocketMaxSpeed do
			speed += rocketConfig.rocketAccel
			bv.Velocity = (main.CFrame * inaccuracy).LookVector * speed
			wait(0.1)
		end
	end))

end)

--death fix
hum.Died:Connect(function()
	print("test")
	camera.CameraType = Enum.CameraType.Custom
	camera.FieldOfView = 70
	camera.CameraSubject = hum
	script:Destroy()
end)