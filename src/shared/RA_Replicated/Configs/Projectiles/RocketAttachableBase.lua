--[[
a little config table to avoid duplicating this in every single rocket config
defines what the attachmodel behavior of a rocket should be
]]

local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local DetachAndRemove = require(dir.Modules.OnFire.DetachAndRemove)
local ParticleActivator, ParticleActivatorConfig = require(dir.Modules.FX.ParticleActivator),
{
	["lookFor"] = "Particles",
	["playFor"] = 0.15,
	["avoidDestruction"] = true
}

local RocketAttachableBase = {
	ClientModelOnUse = {
		ParticleActivator = ParticleActivatorConfig;
	};
	ClientModelOnAttach = {};
	ClientModelOnDetach = {
		DetachAndRemove = {}
	};

	ServerModelOnUse = {
		ParticleActivator = ParticleActivatorConfig;
	};
	ServerModelOnAttach = {};
	ServerModelOnDetach = {
		DetachAndRemove = {}
	};
}

return RocketAttachableBase