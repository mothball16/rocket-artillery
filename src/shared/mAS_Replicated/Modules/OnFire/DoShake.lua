--#region required
local dir = require(script.Parent.Parent.Parent.Directory)
local Shake = require(dir.Utility.Shake)
--#endregion required
--[[
causes a shaking effect using sleitnicks Shake module
]]

local camera = game.Workspace.CurrentCamera
local DoShake = {}

local fallbacks = {
    ["amplitude"] = 1;
}

function DoShake:Execute(config, _)
	config = dir.Helpers:TableOverwrite(fallbacks, config)
	local priority = Enum.RenderPriority.Last.Value

	local shake = Shake.new()
	shake.FadeInTime = 0
	shake.Frequency = 0.1
	shake.Amplitude = config["amplitude"]
	shake.PositionInfluence = Vector3.new(0, 0, 0)

	shake.RotationInfluence = Vector3.new(0.01, 0.01, 0.01)

	shake:Start()
	shake:BindToRenderStep(Shake.NextRenderName(), priority, function(pos, rot, isDone)
		camera.CFrame *= CFrame.new(pos) * CFrame.Angles(rot.X, rot.Y, rot.Z)
	end)
end


return DoShake