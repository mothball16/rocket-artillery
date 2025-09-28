local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local ParticleActivator = require(dir.Modules.OnFire.ParticleActivator)

local RocketAttachableBase = {
	ClientModelOnUse = {
		ParticleActivator.new({
			["lookFor"] = "Particles",
			["lifeTime"] = 0.5
		})
	};
	ClientModelOnAttach = {};
	ClientModelOnDetach = {};

	ServerModelOnUse = {
		ParticleActivator.new({
			["lookFor"] = "Particles",
			["lifeTime"] = 0.5
		})
	};
	ServerModelOnAttach = {};
	ServerModelOnDetach = {};
}

return RocketAttachableBase