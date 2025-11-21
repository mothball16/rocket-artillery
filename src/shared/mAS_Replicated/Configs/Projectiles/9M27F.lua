--#region requires
local dir = require(script.Parent.Parent.Parent.Directory)
local RocketAttachableBase = require(script.Parent.RocketAttachableBase)

local RocketController = require(dir.Modules.OnFire.RocketController)
local GoShake = require(dir.Modules.OnHit.GoShake)
local DoShake = require(dir.Modules.OnFire.DoShake)
local FX = require(dir.Modules.FX.FX)

local GoBoom = require(dir.Modules.OnHit.GoBoom)
--#endregion

local Rocket_9M27F = {
	-- gen. config
	ID = script.Name;
	name = "220mm 9M27F Unguided Rocket, HE-Frag";
	offset = 8;
}

-- for attachables
Rocket_9M27F.SlotTypes = { "BM27" };
dir.Helpers:TableCombine(Rocket_9M27F, RocketAttachableBase)

-- for funcs
Rocket_9M27F.OnFire = {
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
Rocket_9M27F.OnHit = {
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
Rocket_9M27F.FlightPathArgs = Rocket_9M27F.OnFire[1].data;


return Rocket_9M27F