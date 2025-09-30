local dir = require(game.ReplicatedStorage.Shared.RA_Directory)

local function InitEvents()
	dir.Net:RemoteEvent(dir.Events.OnDestroy)
	dir.Net:RemoteEvent(dir.Events.OnInitialize)
	dir.Net:UnreliableRemoteEvent(dir.Events.OnTurretWeldsUpdated)
end

dir.Net:ConnectUnreliable(dir.Events.OnTurretWeldsUpdated, function(player, state, x, y)
	state:SetAttribute("X", x)
	state:SetAttribute("Y", y)
end)

InitEvents()




--[=[

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

]=]