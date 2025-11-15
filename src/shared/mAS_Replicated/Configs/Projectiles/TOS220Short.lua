--#region requires
local dir = require(script.Parent.Parent.Parent.Directory)
local RocketAttachableBase = require(script.Parent.RocketAttachableBase)

local RocketController = require(dir.Modules.OnFire.RocketController)
local GoShake = require(dir.Modules.OnHit.GoShake)
local DoShake = require(dir.Modules.OnFire.DoShake)
local FX = require(dir.Modules.FX.FX)

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
		["burnIn"] = 0; ["burnOut"] = 0.6;
		["arc"] = 0.4; ["speedArcRel"] = 0.65; ["initInacc"] = 1.5;
		["despawn"] = 10;
		["shakeIntensity"] = 1.5;
	}},
	{func = FX.Activate, replicateAcrossClients = true},
	{func = DoShake, data = {["amplitude"] = 1.5}},
};

TOS220Short.OnHit = {
	{func = GoBoom, data = {
		["blastRadius"] = 60,
		["blastPressure"] = 1000,
		["maxDamage"] = 150,
		["breakJoints"] = false,
		["showExplosion"] = false,
	}},
	{func = GoShake, data = {
		["shakeRadius"] = 100,
		["amplitude"] = 20,
	}},
	{func = FX.Create, data = {
		["useFX"] = "RocketMediumExplosion",
	}},
	{func = FX.Preserve, replicateAcrossClients = true}
};

-- for rangefinder/FCU
TOS220Short.FlightPathArgs = TOS220Short.OnFire[1].data;

-- for attachables
TOS220Short.SlotTypes = { "TOSSeries" };
dir.Helpers:TableCombine(TOS220Short, RocketAttachableBase)

return TOS220Short