local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local conf = require(dir.Utility.FallbackConfig)

local ParticleActivator = {}
ParticleActivator.__index = ParticleActivator


-- notes for future refactoring - i'm not too sure about putting the callback here
-- maybe attach a bindable to report back that our arc has finished instead, or just poll (easier)?
-- TODO: this would probably do better as a use and dump instead of making a weird set of coroutines

local fallbacks = {
	["delay"] = 0,
	["lookFor"] = "Particles"
}

function ParticleActivator.new(args, callback)
	local self = {}
	self.config = conf.new(args, fallbacks)
	self.onHit = callback
	setmetatable(self, ParticleActivator)
	return self
end


function ParticleActivator:Execute(main, _)
	for _, v in pairs(main.Parent:GetChildren()) do
		if v.Name == self.config:Get("lookFor") then
			for _, b in pairs(v:GetChildren()) do
				if b:IsA("ParticleEmitter") or b:IsA("Trail") 
					or b:IsA("Beam") or b:IsA("Smoke") then
				b.Enabled = true
			end
			end
		end
	end
end

function ParticleActivator:Destroy()
	self.maid:Destroy()
end

return ParticleActivator