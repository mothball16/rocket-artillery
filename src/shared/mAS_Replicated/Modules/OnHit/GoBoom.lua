local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local conf = require(dir.Utility.FallbackConfig)
local GoBoom = {}

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

function GoBoom:ExecuteOnClient(config, args)
	
end

function GoBoom:ExecuteOnServer(plr, config, args)
	config = dir.FallbackConfig.new(config, fallbacks)
	local exp = Instance.new("Explosion", game.Workspace)
	exp.Position = args.pos
	exp.BlastRadius = config:Get("blastRadius")
	exp.BlastPressure = config:Get("blastPressure")
	exp.DestroyJointRadiusPercent = 0
	exp.ExplosionType = Enum.ExplosionType.NoCraters
	exp.Hit:Connect(function(part)
		if config.breakJoints == true then
			if part.Anchored == false then
				part:BreakJoints()
			end
		end
		if part.Name == "Head" and part.Parent:FindFirstChild("Humanoid") then
			local mag = (exp.Position - part.Position).Magnitude
			local damagePercent = 1 - mag/exp.BlastRadius
			local damageFinal = config:Get("maxDamage") * damagePercent
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