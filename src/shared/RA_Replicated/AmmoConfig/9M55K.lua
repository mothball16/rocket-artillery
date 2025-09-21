local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local onHit = require(dir.Modules.AttackTypes.GoBoom)
local Settings = {
	rocketArc = 10
	,rocketSpeed = 25
	,rocketAccel = 80 --applied 10x/sec
	,inaccuracy = 1
	,rocketMaxSpeed = 600
	,particleDelay = 0
	,burnout = 10
	
	--not required, but since most rockets will end up using this i put it here
	,blastRadius = 40
	,blastPressure = 20000
	,breakJoints = false
	,maxDamage = 300
	,hitEffect = onHit.new()
}

return Settings