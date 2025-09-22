local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local net, evts = dir.GetNetwork()
local RASetup = require(dir.Modules.Core.RASetup)

--[[
local Update = dir.Events:WaitForChild("UpdateWelds")
local Fire = dir.Events:WaitForChild("FireRocket")
local Hit = dir.Events:WaitForChild("HitEffect")
local RepRocket = dir.Events:WaitForChild("ReplicateRocket")
local ReloadRocket = dir.Events:WaitForChild("ReloadRocket")]]
local CS = game:GetService("CollectionService")
local TAG_NAME = "mothballRASystem"


local function InitEvents()
	net:RemoteEvent(evts.OnSeated)
	net:RemoteEvent(evts.OnUnseated)
	net:UnreliableRemoteEvent(evts.OnTurretWeldsUpdated)
end
InitEvents()


local function SetupTurret(required)
    local controlSeat = required:FindFirstChild("ControlSeat")
    local rotMotor = required:FindFirstChild("RotMotor")
    local pitchMotor = required:FindFirstChild("PitchMotor")

    assert(rotMotor and pitchMotor and controlSeat, "turret setup failed: missing required children in folder")
    assert(rotMotor.Value and rotMotor.Value:IsA("ManualWeld"), "turret setup failed: no/invalid rotMotor assigned")
    assert(pitchMotor.Value and pitchMotor.Value:IsA("ManualWeld"), "turret setup failed: no/invalid pitchMotor assigned")

	print(TAG_NAME .. ": vehicle initialized successfully")
    RASetup.SetupTurret(required)
end

for _, v in ipairs(CS:GetTagged(TAG_NAME)) do
    SetupTurret(v)
end

CS:GetInstanceAddedSignal(TAG_NAME):Connect(SetupTurret)





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