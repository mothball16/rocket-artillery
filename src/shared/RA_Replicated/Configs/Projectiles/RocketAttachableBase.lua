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
		{func = ParticleActivator, data = ParticleActivatorConfig};
	};
	ClientModelOnAttach = {};
	ClientModelOnDetach = {
		{func = DetachAndRemove}
	};

	ServerModelOnUse = {
		{func = ParticleActivator, data = ParticleActivatorConfig};
	};
	ServerModelOnAttach = {};
	ServerModelOnDetach = {
		{func = DetachAndRemove}
	};
}

return RocketAttachableBase