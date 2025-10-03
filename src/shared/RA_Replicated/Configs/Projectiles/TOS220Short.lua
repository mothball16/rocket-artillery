--#region requires
local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local RocketAttachableBase = require(script.Parent.RocketAttachableBase)
local UnguidedArc = require(dir.Modules.OnFire.UnguidedArc)
local ParticleActivator = require(dir.Modules.OnFire.ParticleActivator)
local GoBoom = require(dir.Modules.OnHit.GoBoom).new({
	["blastRadius"] = 60,
	["blastPressure"] = 1000,
	["breakJoints"] = false,
	["maxDamage"] = 150
})
--#endregion

local TOS220Short = {
	-- gen. config
	name = "220mm MO.1.01.04 Thermobaric";

	-- attachable config
	slot = { "TOSSeries" };

	-- projectile config

	GoBoom = {
		["blastRadius"] = 60,
		["blastPressure"] = 1000,
		["breakJoints"] = false,
		["maxDamage"] = 150
	};

	OnFire = {
		UnguidedArc.new({
			["initSpeed"] = 30; ["maxSpeed"] = 600; ["accel"] = 800;
			["burnIn"] = 0; ["burnOut"] = 1;
			["arc"] = 10; ["initInacc"] = 1.5; ["flyInacc"] = 0.1;
			["despawn"] = 10;
			["onHit"] = GoBoom.ClientExecute;
		}),
		ParticleActivator.new({})
	};
	OnHit = {
		GoBoom.ServerExecute
	};
}
dir.Helpers:TableCombine(TOS220Short, RocketAttachableBase)

return TOS220Short