--#region requires
local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local RocketAttachableBase = require(script.Parent.RocketAttachableBase)
local RocketController = require(dir.Modules.OnFire.RocketController)
local FXActivator = require(dir.Modules.FX.FXActivator)
local FXCreator = require(dir.Modules.FX.FXCreator)
local GoBoom = require(dir.Modules.OnHit.GoBoom)
--#endregion

local TOS220Short = {
	-- gen. config
	name = "220mm MO.1.01.04 Thermobaric";
}


-- for funcs
TOS220Short.OnFire = {
	{func = RocketController, data = {
		["initSpeed"] = 30; ["maxSpeed"] = 600;
		["burnIn"] = 0; ["burnOut"] = 1;
		["arc"] = 0.4; ["initInacc"] = 1.5;
		["despawn"] = 10;
	}},
	{func = FXActivator, replicate = true}
};

TOS220Short.OnHit = {
	--{func = FXActivator, replicate = true},
	{func = GoBoom, data = {
		["blastRadius"] = 60,
		["blastPressure"] = 1000,
		["maxDamage"] = 150,
		["breakJoints"] = false,
		["showExplosion"] = false,
	}},
	{func = FXCreator, data = {
		["useFX"] = "RocketMediumExplosion",
	}}
};

-- for rangefinder/FCU
TOS220Short.FlightPathArgs = TOS220Short.OnFire[1].data;

-- for attachables
TOS220Short.slot = { "TOSSeries" };
dir.Helpers:TableCombine(TOS220Short, RocketAttachableBase)

return TOS220Short