local dir = require(script.Parent.Parent.Parent.Directory)
local DoShake = require(dir.Modules.OnFire.DoShake)
local GoShake = {}
local plr = game.Players.LocalPlayer

local fallbacks = {
	["shakeRadius"] = 16,
	["amplitude"] = 1,
	["falloffExp"] = 1.3, -- higher value = effect% drops later than linear
}

function GoShake:ExecuteOnClient(config, args: {pos: Vector3})
	config = dir.Helpers:TableOverwrite(fallbacks, config)

	local head = plr.Character and plr.Character:FindFirstChild("Head")
	if not head then return end
	local mag = (head.Position - args.pos).Magnitude
	if mag > config["shakeRadius"] then return end

	local scale = 1 - math.pow((mag / config["shakeRadius"]), config["falloffExp"])
	DoShake:Execute({amplitude = config["amplitude"] * scale})
end

function GoShake:ExecuteOnServer(orig, config, args)
	dir.NetUtils:FireOtherClients(orig, dir.Events.Reliable.OnShake, config, args)
end
return GoShake