--#region required
local dir = require(script.Parent.Parent.Parent.Directory)
--#endregion required
--[[
activates particles on an ALREADY EXISTING object on the server
if the object isn't on the server, use FXCreator instead
]]


local FXActivator = {}

local fallbacks = {
	["delay"] = 0,
	["lookFor"] = "FXEmit",
	["playFor"] = 1,
	["avoidDestruction"] = false
}

local function FireFX(config, FXHolder, disableEffect)
	-- if the thing being activated is about to be destroyed (onHit particles, bla bla)
	-- then eject particles from the model so that they arent destroyed : o
	if config["avoidDestruction"] then
		FXHolder = FXHolder:Clone()
		FXHolder.Parent = game.Workspace.IgnoreList
		FXHolder.Anchored = true
		FXHolder.CanCollide = false
		FXHolder.CanQuery = false
	end

	local maxEmitLength = 0
	for _, fx in pairs(FXHolder:GetChildren()) do
		local isEmitter = fx:IsA("ParticleEmitter") or fx:IsA("Trail") or fx:IsA("Beam") or fx:IsA("Smoke")
		local emitLength = fx:GetAttribute("PlayFor") or config["playFor"]
		maxEmitLength = math.max(maxEmitLength, emitLength)
		if not disableEffect then
			if isEmitter then
				fx.Enabled = true

				task.delay(emitLength, function()
					fx.Enabled = false
				end)
			elseif fx:IsA("Sound") then
				fx.TimePosition = 0
				fx:Play()
			end
		end
	end

	if config["avoidDestruction"] then
		game.Debris:AddItem(FXHolder, 30 + maxEmitLength)
	end
end

function FXActivator:ExecuteOnClient(config, args)
	config = dir.Helpers:TableOverwrite(fallbacks, config)
	for _, holder in pairs(args.object:GetChildren()) do
		if holder.Name == config["lookFor"] then
			FireFX(config, holder, false)
		end
	end
end

-- particles should not be played on the server (Bad!!)
-- this just ticks the avoidDestruction so particles aren't prematurely deleted
-- and also tells other clients to replicate
function FXActivator:ExecuteOnServer(plr, config, args)
	config = dir.Helpers:TableOverwrite(fallbacks, config)

	-- accessible from the server, just run it on that
	for _, holder in pairs(args.object:GetChildren()) do
		if holder.Name == config["lookFor"] then
			FireFX(config, holder, true)
		end
	end

	dir.NetUtils:FireOtherClients(plr, dir.Events.Reliable.OnParticlePlayed, config, args)

end



-- required for validator check, nothing to destroy tho really
function FXActivator:Destroy()
end

return FXActivator