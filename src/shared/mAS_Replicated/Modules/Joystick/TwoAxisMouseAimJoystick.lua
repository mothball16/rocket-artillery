--#region required
local dir = require(script.Parent.Parent.Parent.Directory)
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
rotates towards the 
all joysticks should implement GetInput(), will be asserted on validation
]]
local mouse = game.Players.LocalPlayer:GetMouse()

local fallbacks = {
    enabled = true;
    lockedX = false;
    lockedY = false;
}
local AimToMouseJoystick = {}
AimToMouseJoystick.__index = AimToMouseJoystick

local function _checkSetup()
    
end

function AimToMouseJoystick.new(args, required)
    local self = setmetatable({
        config = dir.Helpers:TableOverwrite(fallbacks, args),
        lockedX = args.lockedX,
        lockedY = args.lockedY,
        enabled = args.enabled,
        OrientationReader = args.OrientationReader,
        TwoAxisRotator = args.TwoAxisRotator
    }, AimToMouseJoystick)

    return self
end

function AimToMouseJoystick:SetFrame(frame)
    self.frame = frame
end

-- return arg 1 is the real input. return arg 2 is the raw input before applying any funny business
function AimToMouseJoystick:GetInput()

    if not self.enabled or not self.frame then
        return Vector2.new(), inputRaw
    end

    if math.abs(xRatio) < deadzone.X or self.lockedX then
        xRatio = 0
    end

    if math.abs(yRatio) < deadzone.Y or self.lockedY then
        yRatio = 0
    end
    return Vector2.new(xRatio, yRatio), inputRaw
end

function AimToMouseJoystick:CanEnable()
    return true
end

function AimToMouseJoystick:Destroy()
    
end

function AimToMouseJoystick:Enable()
    self.enabled = true
end

function AimToMouseJoystick:Disable()
    self.enabled = false
end


return AimToMouseJoystick

