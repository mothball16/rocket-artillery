--#region required
local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
This is the purpose of this script.
]]

local DetachAndRemove = {}
DetachAndRemove.__index = DetachAndRemove

local fallbacks = {

}

local function _checkSetup(required)
	
end
function DetachAndRemove.new(args, required)
	local self = setmetatable({}, DetachAndRemove)
	self.config = dir.FallbackConfig.new(args, fallbacks)
	return self
end


function DetachAndRemove:Execute(main, required)
	for _, v in pairs(main.Parent:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
			v.Transparency = 1
			v.CanCollide = false
			v.Massless = true
		end
	end
end


return DetachAndRemove