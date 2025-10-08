--#region required
local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
This is the purpose of this script.
]]

local DetachAndRemove = {}

local fallbacks = {}

function DetachAndRemove:Execute(config, main, required)
	local config = dir.FallbackConfig.new(config, fallbacks)
	for _, v in pairs(main.Parent:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
			v.Transparency = 1
			v.CanCollide = false
			v.CanQuery = false
		end
	end
	main.Parent.Parent = game.Workspace

end


return DetachAndRemove