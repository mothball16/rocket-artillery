--[[
a little config table to avoid duplicating this in every single rocket config
defines what the attachmodel behavior of a rocket should be
]]

local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local DetachAndRemove = require(dir.Modules.OnFire.DetachAndRemove)
local FXActivator, FXActivatorConfig = require(dir.Modules.FX.FXActivator),
{
	["playFor"] = 0.15,
	["avoidDestruction"] = true
}

local RocketAttachableBase = {
	ClientModelOnUse = {
		{func = FXActivator, data = FXActivatorConfig};
	};
	ClientModelOnAttach = {};
	ClientModelOnDetach = {
		{func = DetachAndRemove}
	};

	ServerModelOnUse = {
		{func = FXActivator, data = FXActivatorConfig};
	};
	ServerModelOnAttach = {};
	ServerModelOnDetach = {
		{func = DetachAndRemove}
	};
}

return RocketAttachableBase