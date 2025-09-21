local Settings = {
	rocketArc = 10;
	rocketSpeed = 25;
	rocketAccel = 80; --applied 10x/sec
	inaccuracy = 1.5;
	rocketMaxSpeed = 600;
	particleDelay = 0;
	burnout = 10;
	
	--not required, but since most rockets will end up using this i put it here
	blastRadius = 60;
	blastPressure = 20000;
	breakJoints = false;
	maxDamage = 200;
	
	
	hitEffect = function(config,pos)
		--[[]]
		--	print(result)
		local exp = Instance.new("Explosion",game.Workspace)
		exp.Position = pos
		exp.BlastRadius = config.blastRadius
		exp.BlastPressure = config.blastPressure
		exp.DestroyJointRadiusPercent = 0
		exp.ExplosionType = Enum.ExplosionType.NoCraters
		exp.Hit:Connect(function(part)
			if config.breakJoints == true then
				if part.Anchored == false then
					part:BreakJoints()
				end
			end
			if part.Name == "Head" and part.Parent:FindFirstChild("Humanoid") then
				local mag = (exp.Position - part.Position).Magnitude
				local damagePercent = 1 - mag/exp.BlastRadius
				part.Parent:FindFirstChild("Humanoid"):TakeDamage(config.maxDamage*damagePercent)
			end
		end)
		local effects = game.ReplicatedStorage:WaitForChild("RARequired"):WaitForChild("Resources"):WaitForChild("Explosion"):Clone()
		effects.Parent = game.Workspace
		effects.Position = pos
		for i,v in pairs(effects:GetChildren()) do
			delay(0.15,function()
				v.Enabled = false
			end)
		end
		game.Debris:AddItem(effects,4)
	end;
}

return Settings