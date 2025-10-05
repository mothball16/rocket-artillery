local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local conf = require(dir.Utility.FallbackConfig)
local GoBoom = {}
GoBoom.__index = GoBoom

local fallbacks = {
	["blastRadius"] = 16,
	["blastPressure"] = 10000,
	["breakJoints"] = false,
	["maxDamage"] = 200,
}

function GoBoom.new(args)
	local self = {}
	self.config = conf.new(args, fallbacks)
	self.blastRadius = self.config:Get("blastRadius")
	setmetatable(self, GoBoom)
	return self
end

function GoBoom:ExecuteOnClient(pos)
	
end

function GoBoom:ExecuteOnServer(pos)
	local exp = Instance.new("Explosion", game.Workspace)
	exp.Position = pos
	exp.BlastRadius = self.config.blastRadius
	exp.BlastPressure = self.config.blastPressure
	exp.DestroyJointRadiusPercent = 0
	exp.ExplosionType = Enum.ExplosionType.NoCraters
	exp.Hit:Connect(function(part)
		if self.config.breakJoints == true then
			if part.Anchored == false then
				part:BreakJoints()
			end
		end
		if part.Name == "Head" and part.Parent:FindFirstChild("Humanoid") then
			local mag = (exp.Position - part.Position).Magnitude
			local damagePercent = 1 - mag/exp.BlastRadius
			local damageFinal = self.config:Get("maxDamage") * damagePercent
			part.Parent:FindFirstChild("Humanoid"):TakeDamage(damageFinal)
		end
	end)
	--[[
	local effects = dir.Shared:WaitForChild("Resources"):WaitForChild("Explosion"):Clone()
	effects.Parent = game.Workspace
	effects.Position = pos
	for i,v in pairs(effects:GetChildren()) do
		delay(0.15,function()
			v.Enabled = false
		end)
	end
	game.Debris:AddItem(effects,4)]]
end
return GoBoom