--#region required
local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
re-parents particles outside of the original object and sets debris to however long they will play for
]]

local controller = {}
local fallbacks = {
    ["useFX"] = "RocketMediumExplosion",
    ["playFor"] = 0.25,
    ["lookFor"] = "FXEmit",
}


local function SetupFXPreserve(config, emitterPart: BasePart)
    local debrisTime = 0
    for _, fx in pairs(emitterPart:GetChildren()) do
		local emitLength = fx:GetAttribute("PlayFor") or config:Get("playFor")
		debrisTime = math.max(debrisTime, emitLength)
        dir.Helpers:Switch (fx.ClassName) {
            ["ParticleEmitter"] = function()
                fx = fx :: ParticleEmitter
                debrisTime = math.max(debrisTime, emitLength + fx.Lifetime.Max)
                fx.Enabled = false
            end;
            ["Trail"] = function()
                fx = fx :: Trail
                debrisTime = math.max(debrisTime, emitLength + fx.Lifetime)
                fx.Enabled = false
            end;
            default = function() 
                debrisTime = math.max(debrisTime, emitLength)
                if fx.Enabled then fx.Enabled = false end
            end
        }
	end

    emitterPart.Parent = game.Workspace.IgnoreList
    emitterPart.CanCollide = false
    emitterPart.CanQuery = false
    emitterPart.Transparency = 1
    emitterPart.Anchored = true
    game.Debris:AddItem(emitterPart, debrisTime)
end

function controller:ExecuteOnClient(config, args)
    print("yo", args)
    config = dir.FallbackConfig.new(config, fallbacks)
	for _, holder in pairs(args.object:GetChildren()) do
		if holder.Name == config:Get("lookFor") then
			SetupFXPreserve(config, holder)
		end
	end
end

function controller:ExecuteOnServer(plr, config, args)

end

return controller
