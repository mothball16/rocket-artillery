local dir = require(script.Parent.Parent.Parent.Directory)
local GoBoom = {}

local fallbacks = {
	["blastRadius"] = 16,
	["blastPressure"] = 10000,
	["breakJoints"] = "IfJointDestroyable", -- "None", "IfDestroyable", "All (not recommended)"
	["maxDamage"] = 200,
	["showExplosion"] = false,
}

function GoBoom:ExecuteOnClient(config, args)
	
end

function GoBoom:ExecuteOnServer(plr, config, args)
	config = dir.Helpers:TableOverwrite(fallbacks, config)

	local exp = Instance.new("Explosion", game.Workspace)
	exp.Position = args.pos
	exp.BlastRadius = config["blastRadius"]
	exp.BlastPressure = config["blastPressure"]
	exp.DestroyJointRadiusPercent = 0
	exp.ExplosionType = Enum.ExplosionType.NoCraters
	exp.Visible = config["showExplosion"]

	local function CalcDamage(pos)
		local mag = (exp.Position - pos).Magnitude
		local damagePercent = 1 - mag/exp.BlastRadius
		return config["maxDamage"] * damagePercent
	end

	exp.Hit:Connect(function(part)
		dir.Helpers:Switch (config["breakJoints"]) {
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