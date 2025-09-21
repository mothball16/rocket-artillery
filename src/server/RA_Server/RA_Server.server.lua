local resources = game.ReplicatedStorage:WaitForChild("RARequired")
local Update = resources:WaitForChild("Events"):WaitForChild("UpdateWelds")
local Fire = resources:WaitForChild("Events"):WaitForChild("FireRocket")
local Hit = resources:WaitForChild("Events"):WaitForChild("HitEffect")
local RepRocket = resources:WaitForChild("Events"):WaitForChild("ReplicateRocket")
local ReloadRocket = resources:WaitForChild("Events"):WaitForChild("ReloadRocket")

Update.OnServerEvent:Connect(function(plr,required,yaw,pitch)
	for i,v in pairs(game.Players:GetChildren()) do
		if v ~= plr then
			Update:FireClient(v,required,yaw,pitch)
		end
	end
end)

Fire.OnServerEvent:Connect(function()
	
end)

Hit.OnServerEvent:Connect(function(plr,config,pos)
	config = require(config)
	config.hitEffect(config,pos)
end)

RepRocket.OnServerEvent:Connect(function(plr,base,config,inacc)
	base:FindFirstChild("Ready").Value = false
	for i,v in pairs(base:GetChildren()) do
		if v:IsA("BasePart") then v.Transparency = 1 end
	end
	base:FindFirstChild("ReloadBox").ProximityPrompt.Enabled = true
	for i,v in pairs(game.Players:GetChildren()) do
		if v ~= plr then
			RepRocket:FireClient(v,base,config,inacc)
		end
	end
end)

ReloadRocket.OnServerEvent:Connect(function(plr,rocket)
	
end)