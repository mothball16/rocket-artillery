--[[
a little config table to avoid duplicating this in every single rocket config
defines what the attachmodel behavior of a rocket should be
]]

local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local ParticleActivator = require(dir.Modules.FX.ParticleActivator).new({
	["lookFor"] = "Particles",
	["playFor"] = 0.15,
	["avoidDestruction"] = true
})
local DetachAndRemove = require(dir.Modules.OnFire.DetachAndRemove).new({})

local RocketAttachableBase = {
	ClientModelOnUse = {
		ParticleActivator
	};
	ClientModelOnAttach = {};
	ClientModelOnDetach = {
		DetachAndRemove
	};

	ServerModelOnUse = {
		ParticleActivator
	};
	ServerModelOnAttach = {};
	ServerModelOnDetach = {
		DetachAndRemove
	};
}

return RocketAttachableBase