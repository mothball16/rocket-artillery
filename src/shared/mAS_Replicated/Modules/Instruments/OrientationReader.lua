--#region required
local dir = require(script.Parent.Parent.Parent.Directory)
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
provides the global orientation of a part 
]]

local OrientationReader = {}
OrientationReader.__index = OrientationReader

local function _checkSetup(required)
    return validator:ValueIsOfClass(required:FindFirstChild("OrientationReader"), "BasePart")
end
function OrientationReader.new(args, required)
    local self = setmetatable({}, OrientationReader)
    self.main = _checkSetup(required)
    return self
end

function OrientationReader:GetDirection()
    local Y, X, Z = self.main.CFrame:ToEulerAnglesYXZ()
    return {
        yaw = math.deg(X);
        pitch = math.deg(Y);
        roll = math.deg(Z);
    }
end

function OrientationReader:GetPos()
    return self.main.Position
end

function OrientationReader:GetForwardPos(forward)
    return (self.main.CFrame * CFrame.new(0,0,-forward)).Position
end

function OrientationReader:Destroy()
    
end

return OrientationReader