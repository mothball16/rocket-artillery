local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local conf = require(dir.Utility.FallbackConfig)
local GoBoom = {}

local fallbacks = {
	["blastRadius"] = 16,
	["blastPressure"] = 10000,
	["breakJoints"] = "IfJointDestroyable", -- "None", "IfDestroyable", "All (not recommended)"
	["maxDamage"] = 200,
	["showExplosion"] = false,
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
	exp.Visible = config:Get("showExplosion")

	local function CalcDamage(pos)
		local mag = (exp.Position - pos).Magnitude
		local damagePercent = 1 - mag/exp.BlastRadius
		return config:Get("maxDamage") * damagePercent
	end

	exp.Hit:Connect(function(part)
		dir.Helpers:Switch (config:Get("breakJoints")) {
			["IfJointDestroyable"] = function()
				for _, v in pairs(part:GetJoints()) do
					local partHealth = v:GetAttribute(dir.Consts.DESTROYABLE_JOINT_ATTR)
					if not partHealth then continue end
					local finalHealth = partHealth - CalcDamage(part.Position)
					v:SetAttribute(dir.Consts.DESTROYABLE_JOINT_ATTR, finalHealth)
					if finalHealth <= 0 then
						v:Destroy()
					end
				end
			end,
			
			["All"] = function()
				for _, v in pairs(part:GetJoints()) do
					v:Destroy()
				end
			end,

			default = function() end
		}

		if part.Name == "Head" and part.Parent:FindFirstChild("Humanoid") then
			part.Parent:FindFirstChild("Humanoid"):TakeDamage(CalcDamage(part.Position))
		end
	end)
end
return GoBoom