local runService = game:GetService("RunService")
local tweenservice = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local required = script.Parent:WaitForChild("Required").Value
repeat required = script.Parent:WaitForChild("Required").Value until required ~= nil

local values = required.Parent:WaitForChild("Values")
local config = require(required.Parent:WaitForChild("Config"))
local RArequired = game.ReplicatedStorage:WaitForChild("RARequired")


local plr = game.Players.LocalPlayer
local timeElapsed = 0
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local mouse = game.Players.LocalPlayer:GetMouse()
local camera = game.Workspace.CurrentCamera



local curRot = values:WaitForChild("Deflection")
local curElev = values:WaitForChild("Elevation")

local deadZone = config.deadzoneSize
local minRot = config.minDeflection
local maxRot = config.maxDeflection
local minElev = config.minElevation
local maxElev = config.maxElevation
local elevSpeed =  config.elevSpeed
local rotSpeed = config.rotSpeed
local fireIndex = 1
local salvoIndex = 1
local count = 0
local ready = 0
local sideOffset = 0

local canTurn = true
local canFire = true
local isFiring = false
local zoomingIn = false
local zoomingOut = false
local comp = 1/60

local connections = {}
local hud = script.Parent
mouse.TargetFilter = required.Parent
camera.CameraType = Enum.CameraType.Scriptable
camera.CameraSubject = required:WaitForChild("Camera")

function roundNumber(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function calculateAmmo()
	count = 0
	ready = 0
	for i,v in pairs(required:WaitForChild("RocketHolder"):GetChildren()) do
		count += 1
		if v:FindFirstChild("Ready").Value == true then
			ready += 1
		end
	end
	return {count,ready}
end

calculateAmmo()

function fireRocket()
	local baseRocket = nil
	for i,v in pairs(required:WaitForChild("RocketHolder"):GetChildren()) do
		if v:FindFirstChild("Ready").Value == true then
			baseRocket = v
			break
		end
	end
	if baseRocket ~= nil then
		baseRocket:FindFirstChild("Ready").Value = false
		for i,v in pairs(baseRocket:GetChildren()) do
			if v:IsA("BasePart") then v.Transparency = 1 end
		end
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
		
		
	end
	calculateAmmo()
	--[[
	local active = true
	local oldpos = nil
	local rocket = RArequired.AmmoTypes:FindFirstChild(config.ammoType):Clone()
	local main = rocket:WaitForChild("Main")
	local rocketConfig = require(RArequired.AmmoConfig:FindFirstChild(config.ammoType))
	rocket.Parent = game.Workspace
	rocket:SetPrimaryPartCFrame(origin.CFrame * CFrame.new(0,0,-config.offset))
	main.Orientation = Vector3.new(main.Orientation.X,main.Orientation.Y,0)
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
	
	while rocket.Parent ~= nil and active == true do
		oldpos = main.Position
		main.CFrame  =main.CFrame * CFrame.new(0,0,-rocketConfig.rocketSpeed/60) * CFrame.Angles(math.rad(-rocketConfig.rocketArc/60),0,0)
		--rocket.Main.Orientation = rocket.Main.Orientation + Vector3.new(-config.RocketArc/60*compensation)
		RunService.Heartbeat:Wait()
		if oldpos then
			local rayparams = RaycastParams.new()
			rayparams.FilterDescendantsInstances = {rocket}
			rayparams.FilterType = Enum.RaycastFilterType.Blacklist
			local result = game.Workspace:Raycast(main.Position,oldpos,rayparams)
			if result and result.Instance.Transparency < 1 then
				rocketConfig.hitEffect(rocket,rocketConfig,result)
				active = false
				
			end
		--[[	local distance = (rocket.Main.Position - oldpos).Magnitude
			local p = Instance.new("Part",game.Workspace)
			p.Anchored = true
			p.CanCollide = false
			p.Material = Enum.Material.Neon
			p.Size = Vector3.new(1, 1, distance)
			p.CFrame = CFrame.lookAt(rocket.Main.Position, oldpos)*CFrame.new(0, 0, -distance/2)]]
	--	end
	--end
end

function Raycast(Start, Direction, Ignore)
	return game.Workspace:FindPartOnRayWithIgnoreList(Ray.new(Start, Direction * Vector3.new(config.cameraXOffset,config.cameraYOffset,config.cameraZOffset).Magnitude), Ignore)
end

function cameraLogic()
	local obstructionPercent = 1
	local dir = CFrame.new(
		required:WaitForChild("Camera").Position,
		(required:WaitForChild("Camera").CFrame * CFrame.new(config.cameraXOffset,config.cameraYOffset,config.cameraZOffset)).Position
	).LookVector.Unit
	local hit, pos = game.Workspace:FindPartOnRayWithIgnoreList(Ray.new(required:WaitForChild("Camera").Position, dir * Vector3.new(config.cameraXOffset,config.cameraYOffset,config.cameraZOffset).Magnitude), required:WaitForChild("Vehicle").Value:GetDescendants())

	if hit then
		obstructionPercent =  
			(pos - required:WaitForChild("Camera").Position).Magnitude /
			Vector3.new(sideOffset,config.cameraYOffset,config.cameraZOffset).Magnitude
	end
	camera.CFrame = required:WaitForChild("Camera").CFrame * CFrame.new(sideOffset,config.cameraYOffset*obstructionPercent - 1,config.cameraZOffset*obstructionPercent - 1)
end



function updateUI()
	

	local look = required:FindFirstChild("AimPoint").CFrame.lookVector
	local heading = math.atan2(look.x, look.z)
	heading = math.deg(heading)
	hud.Stats.Deflection.Text = "DFL: " .. roundNumber(-heading+180,1)
	hud.Stats.Elevation.Text = "ELV: " ..  roundNumber(required:FindFirstChild("AimPoint").Orientation.X,1)
	hud.Orient.Turret.Rotation = -(required:FindFirstChild("AimPoint").Orientation.Y - required:FindFirstChild("Base").Orientation.Y) - 45
	hud.Combat.Title.Text = config.vehicleName
	if canTurn then
		hud.Combat.Lock.Text = "FREE"
		hud.Combat.Lock.TextColor3 = Color3.fromRGB(200,255,200)
	else
		hud.Combat.Lock.Text = "LOCK"
		hud.Combat.Lock.TextColor3 = Color3.fromRGB(255,200,200)
	end
	hud.Stats.Zoom.Bar.Size = UDim2.new(1,0,1-((camera.FieldOfView-config.minFOV)/(70-config.minFOV)),0)
	local ignore = required:WaitForChild("Vehicle").Value:GetDescendants()
	local pointDist = 1000
	local hit, pos = workspace:FindPartOnRayWithIgnoreList(Ray.new(required:WaitForChild("AimPoint").Position, required:WaitForChild("AimPoint").CFrame.lookVector * pointDist), ignore);

	if hit then
		pointDist = (required:WaitForChild("AimPoint").Position - pos).Magnitude
	end
	local crosshairPos = game.Workspace.CurrentCamera:WorldToScreenPoint(required:WaitForChild("AimPoint").CFrame * CFrame.new(0,0,-pointDist).Position)

	hud:FindFirstChild("AimPoint").Position = UDim2.new(0,crosshairPos.X,0,crosshairPos.Y)
	hud.Stats.Altitude.Text = "ALT: " .. math.floor(required:FindFirstChild("Base").Position.Y+0.5)
	hud.Stats.Coords.Text = "COORDS: [" .. math.floor(required:FindFirstChild("Base").Position.X+0.5)  .. ", " ..  math.floor(required:FindFirstChild("Base").Position.Z+0.5) .. "]" 
	hud.Combat.Interval.Text = "INT: " .. config.fireInts[fireIndex]
	hud.Combat.Quantity.Text = "QTY: " .. config.fireQts[salvoIndex]
	hud.Combat.Loaded.Text = ready
	hud.Combat.Rockets.Text = count
end

runService.RenderStepped:Connect(function(dt)
	timeElapsed += dt
	--local orig = CFrame.new(required:FindFirstChild("FirePart").Orientation)
	--local x, y, z = CFrame.new(required:FindFirstChild("FirePart").Position,mouse.Hit.Position):ToEulerAnglesYXZ()
--	local aim = Vector3.new(math.deg(x),math.deg(y),math.deg(z))
	if canTurn then
		local res = camera.ViewportSize - Vector2.new(0,36)
		local xRatio = math.max(math.min(3*(mouse.X/res.X) - 1.5,1),-1)
		local yRatio = math.max(math.min(3*(mouse.Y/res.Y) - 1.5,1),-1)
		if math.abs(xRatio) > deadZone then
			if config.deflectionLimit == false or curRot.Value + xRatio * rotSpeed > minRot and curRot.Value + xRatio * rotSpeed < maxRot then
				curRot.Value += xRatio * rotSpeed * dt * 60
				required.Base.Pivot.C1 *= CFrame.Angles(0,math.rad(xRatio * rotSpeed),0)
			end
		end
		if math.abs(yRatio) > deadZone then
			if curElev.Value - yRatio * elevSpeed > minElev and curElev.Value - yRatio * elevSpeed < maxElev then
				curElev.Value -= yRatio * elevSpeed * dt * 60
				required.Elevation.Pivot.C1 *= CFrame.Angles(math.rad(yRatio * elevSpeed),0,0)
			end
		end
		hud.Stats.Aiming.Detail.Stick.Position = UDim2.new(0.8*(0.5*(xRatio+1))+0.1,0,0.8*(0.5*(yRatio+1))+0.1,0)
		
	--	print(math.floor(curRot.Value))
		--required.Base.Pivot.C1 = CFrame.Angles(0,math.rad(-aim.Y),0)
		--required.Elevation.Pivot.C1 = CFrame.Angles(math.rad(math.min(math.max(-aim.X,-30),0)),0,0)
	end
	
	if canTurn == false and hud:WaitForChild("Rangefinder").Visible == true then
		hud:WaitForChild("Rangefinder").Dist.Text = "DIST: " .. math.floor((mouse.Hit.Position-required:WaitForChild("AimPoint").Position).Magnitude)
	else
		hud:WaitForChild("Rangefinder").Dist.Text = "DIST: XXX"
	end
	
	cameraLogic()
	
	
	
	if timeElapsed > 0.15 then
		timeElapsed = 0
		RArequired:WaitForChild("Events"):WaitForChild("UpdateWelds"):FireServer(required,required.Base.Pivot.C1,required.Elevation.Pivot.C1)
	end

	if zoomingIn then
		camera.FieldOfView -= math.min(camera.FieldOfView-config.minFOV,config.FOVspeed*dt)
		if camera.FieldOfView < config.minFOV then
			camera.FieldOfView = config.minFOV
		end
	elseif zoomingOut then
		camera.FieldOfView += math.min(70-camera.FieldOfView,config.FOVspeed*dt)
		if camera.FieldOfView > 70 then
			camera.FieldOfView = 70
		end
	end
	
	
	
end)

runService.Heartbeat:Connect(function(dt)
	comp = dt
	updateUI()
end)

mouse.Button1Down:Connect(function()
	canTurn = not canTurn
end)


UserInputService.InputBegan:Connect(function(key,chatting)
	if not chatting then
		if key.KeyCode == Enum.KeyCode.Q then
			zoomingIn = false
			zoomingOut = true
		elseif key.KeyCode == Enum.KeyCode.E then
			zoomingIn = true
			zoomingOut = false
		elseif key.KeyCode == Enum.KeyCode.F and canFire == true then
			canFire = false
			isFiring = true
			while isFiring == true do
				for i=1,config.fireQts[salvoIndex] do
					fireRocket()
				end
				wait(config.fireInts[fireIndex])
			end
			canFire = true
			--RArequired:WaitForChild("Events").FireRocket:FireServer(required:FindFirstChild("FirePart"),config)

		elseif key.KeyCode == Enum.KeyCode.T then
			hud:WaitForChild("Rangefinder").Visible = not hud:WaitForChild("Rangefinder").Visible
		elseif key.KeyCode == Enum.KeyCode.Z then
			if sideOffset == 0 then
				sideOffset = config.sideOffset
			elseif sideOffset == config.sideOffset then
				sideOffset = -config.sideOffset
			else
				sideOffset = 0
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(key,chatting)
	if not chatting then
		if key.KeyCode == Enum.KeyCode.Q then
			zoomingOut = false
		elseif key.KeyCode == Enum.KeyCode.E then
			zoomingIn = false
		elseif key.KeyCode == Enum.KeyCode.V then
			if config.fireInts[fireIndex+1] ~= nil then
				fireIndex += 1
			else
				fireIndex = 1
			end
		elseif key.KeyCode == Enum.KeyCode.B then
			if config.fireQts[salvoIndex+1] ~= nil then
				salvoIndex += 1
			else
				salvoIndex = 1
			end
		elseif key.KeyCode == Enum.KeyCode.F then
			isFiring = false
		end
	end
end)



hum.Died:Connect(function()
	camera.CameraType = Enum.CameraType.Custom
	camera.FieldOfView = 70
	camera.CameraSubject = hum
	script:Destroy()
end)

hum.Jumping:Connect(function()
	camera.CameraType = Enum.CameraType.Custom
	camera.FieldOfView = 70
	camera.CameraSubject = hum
	script:Destroy()
end)