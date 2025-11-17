--#region required
local dir = require(script.Parent.Parent.Parent.Directory)
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
provides the global orientation of a part. modify this as necessary in case you are using a
different kind of compass system because people cant decide how they want to do it
]]

local OFFSET = 0 -- is the compass offset by 90/180/blah degrees?
local REVERSE = false -- is compass going in the wrong direction (is clockwise reducing instead of increasing the angle?)

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
    local pitch, yaw, roll = self.main.CFrame:ToEulerAnglesYXZ()
    yaw, pitch, roll = math.deg(yaw), math.deg(pitch), math.deg(roll)
    if not REVERSE then -- roblox uses a left-hand coordinate sys. so this has to be flipped
        yaw = 360 - yaw
    end
    yaw += OFFSET
    yaw %= 360

    return {
        yaw = yaw,
        pitch = pitch,
        roll = roll,
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