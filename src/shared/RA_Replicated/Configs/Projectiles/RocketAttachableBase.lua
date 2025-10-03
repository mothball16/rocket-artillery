local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local ParticleActivator = require(dir.Modules.OnFire.ParticleActivator)
local DetachAndRemove = require(dir.Modules.OnFire.DetachAndRemove)
local RocketAttachableBase = {
	ClientModelOnUse = {
		ParticleActivator.new({
			["lookFor"] = "Particles",
			["lifeTime"] = 0.5
		})
	};
	ClientModelOnAttach = {};
	ClientModelOnDetach = {
		DetachAndRemove.new({})
	};

	ServerModelOnUse = {
		ParticleActivator.new({
			["lookFor"] = "Particles",
			["lifeTime"] = 0.5
		})
	};
	ServerModelOnAttach = {};
	ServerModelOnDetach = {
		DetachAndRemove.new({})
	};
}

return RocketAttachableBase