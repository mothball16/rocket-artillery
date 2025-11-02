--#region required
local dir = require(script.Parent.Parent.Parent.Directory)
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
This is the purpose of this script.
]]

local DetachAndRemove = {}

local fallbacks = {}

function DetachAndRemove:Execute(config, args)
	local config = dir.Helpers:TableOverwrite(fallbacks, config)
	for _, v in pairs(args.object:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
			v.Transparency = 1
			v.CanCollide = false
			v.CanQuery = false
		end
	end
	args.object.Parent = game.Workspace
end


return DetachAndRemove