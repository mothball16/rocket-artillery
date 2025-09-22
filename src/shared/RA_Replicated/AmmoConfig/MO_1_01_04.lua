local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local UnguidedArc = require(dir.Modules.OnFire.UnguidedArc)
local GoBoom = require(dir.Modules.OnHit.GoBoom)

return {
	-- gen. config
	name = "220mm MO.1.01.04 Thermobaric";
	slot = { "TOSSeries" };
	
	onFire = UnguidedArc.new({
		["initSpeed"] = 30;
		["maxSpeed"] = 600;
		["accel"] = 800;

		["burnIn"] = 0;
		["burnOut"] = 1;

		["arc"] = 10;
		["initInacc"] = 1.5;
		["flyInacc"] = 0.1;

		["despawn"] = 10;
	});

	-- onHit config
	onHit = GoBoom.new({
		["blastRadius"] = 60,
		["blastPressure"] = 1000,
		["breakJoints"] = false,
		["maxDamage"] = 150
	});
}