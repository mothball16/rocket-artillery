local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local OnParticlePlayed = dir.Net:UnreliableRemoteEvent(dir.Events.Unreliable.OnParticlePlayed)

local ParticleActivator = {}

local fallbacks = {
	["delay"] = 0,
	["lookFor"] = "Particles",
	["playFor"] = 1,
	["avoidDestruction"] = false
}

local function FireParticles(config, holder, disableEffect)
	-- if the thing being activated is about to be destroyed (onHit particles, bla bla)
	-- then eject particles from the model so that they arent destroyed : o
	if config:Get("avoidDestruction") then
		holder = holder:Clone()
		holder.Parent = game.Workspace
		holder.Anchored = true
		holder.CanCollide = false
		holder.CanQuery = false
	end

	local maxEmitLength = 0
	for _, emitter in pairs(holder:GetChildren()) do
		local isEmitter = emitter:IsA("ParticleEmitter") or emitter:IsA("Trail") or emitter:IsA("Beam") or emitter:IsA("Smoke")
		local emitLength = emitter:GetAttribute("PlayFor") or config:Get("playFor")
		maxEmitLength = math.max(maxEmitLength, emitLength)

		if isEmitter and not disableEffect then
			emitter.Enabled = true

			task.delay(emitLength, function()
				emitter.Enabled = false
			end)
		end
	end

	if config:Get("avoidDestruction") then
		game.Debris:AddItem(holder, 30 + maxEmitLength)
			end
end

function ParticleActivator:ExecuteOnClient(config, main)
	config = dir.FallbackConfig.new(config, fallbacks)
	for _, holder in pairs(main.Parent:GetChildren()) do
		if holder.Name == config:Get("lookFor") then
			FireParticles(config, holder, false)
		end
	end
end

-- particles should not be played on the server (Bad!!)
-- this just ticks the avoidDestruction so particles aren't prematurely deleted
-- and also tells other clients to replicate
function ParticleActivator:ExecuteOnServer(plr, config, main)
	config = dir.FallbackConfig.new(config, fallbacks)
	for _, holder in pairs(main.Parent:GetChildren()) do
		if holder.Name == config:Get("lookFor") then
			FireParticles(config, holder, true)
		end
	end
	dir.NetUtils:FireOtherClients(plr, OnParticlePlayed, config:ToRaw(), main, _)
end



-- required for validator check, nothing to destroy tho really
function ParticleActivator:Destroy()
end

return ParticleActivator