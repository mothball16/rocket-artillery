local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local OnParticlePlayed = dir.Net:UnreliableRemoteEvent(dir.Events.Unreliable.OnParticlePlayed)

local ParticleActivator = {}

local fallbacks = {
	["delay"] = 0,
	["lookFor"] = "Particles",
	["playFor"] = 1,
	["avoidDestruction"] = false
}

function ParticleActivator:ExecuteOnClient(config, main)
	config = dir.FallbackConfig.new(config, fallbacks)
	for _, holder in pairs(main.Parent:GetChildren()) do
		if holder.Name == config:Get("lookFor") then
			local maxEmitLength = 0
			for _, emitter in pairs(holder:GetChildren()) do
				local isEmitter = emitter:IsA("ParticleEmitter") or emitter:IsA("Trail") or emitter:IsA("Beam") or emitter:IsA("Smoke")
				local emitLength = emitter:GetAttribute("PlayFor") or config:Get("playFor")
				maxEmitLength = math.max(maxEmitLength, emitLength)

				if isEmitter then
					emitter.Enabled = true

					task.delay(emitLength, function()
						emitter.Enabled = false
					end)
				end
			end

			-- if the thing being activated is about to be destroyed (onHit particles, bla bla)
			-- then eject particles from the model so that they arent destroyed : o
			if config:Get("avoidDestruction") then
				holder.Parent = game.Workspace
				holder.Anchored = true
				holder.CanCollide = false
				holder.CanQuery = false
				game.Debris:AddItem(holder, maxEmitLength + 30)
			end
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
			local maxEmitLength = 0
			for _, emitter in pairs(holder:GetChildren()) do
				local emitLength = emitter:GetAttribute("PlayFor") or config:Get("playFor")
				maxEmitLength = math.max(maxEmitLength, emitLength)
			end

			-- if the thing being activated is about to be destroyed (onHit particles, bla bla)
			-- then eject particles from the model so that they arent destroyed : o
			if config:Get("avoidDestruction") then
				holder.Parent = game.Workspace
				holder.Anchored = true
				holder.CanCollide = false
				holder.CanQuery = false
				game.Debris:AddItem(holder, maxEmitLength + 30)
			end
		end
	end
	dir.NetUtils:FireOtherClients(plr, OnParticlePlayed, config:ToRaw(), main, _)
end



-- required for validator check, nothing to destroy tho really
function ParticleActivator:Destroy()
end

return ParticleActivator