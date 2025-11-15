--#region required
local dir = require(script.Parent.Parent.Parent.Directory)
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
tracks ur mouse on-screen and maps it between -1, 1 on both axes
all joysticks should implement GetInput(), will be asserted on validation
]]
 local mouse = game.Players.LocalPlayer:GetMouse()

local fallbacks = {
    sens = 1;
    deadzone = Vector2.new(0.005,0.005);
    enabled = true;
    lockedX = false;
    lockedY = false;
}
local MouseBasedJoystick = {}
MouseBasedJoystick.__index = MouseBasedJoystick

function MouseBasedJoystick.new(args, required)
    local self = setmetatable({}, MouseBasedJoystick)
    self.config = dir.Helpers:TableOverwrite(fallbacks, args)
    self.lockedX = args.lockedX
    self.lockedY = args.lockedY
    self.enabled = args.enabled
    return self
end

function MouseBasedJoystick:SetFrame(frame)
    self.frame = frame
end

-- return arg 1 is the real input. return arg 2 is the raw input before applying any funny business
function MouseBasedJoystick:GetInput()

    local sens = self.config["sens"]
    local deadzone = self.config["deadzone"] * sens
    local offset = self.frame.AbsolutePosition
    local scale = self.frame.AbsoluteSize
    local mousePropX = (mouse.X - offset.X - scale.X / 2) / scale.X
    local mousePropY = (mouse.Y - offset.Y - scale.Y / 2) / scale.Y

    local xRatio = math.clamp(mousePropX * 2 * sens, -1, 1)
    local yRatio = math.clamp(mousePropY * 2 * sens, -1, 1)
    local inputRaw = Vector2.new(xRatio, yRatio)
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

function MouseBasedJoystick:CanEnable()
    if not self.frame then return false end
    local offset = self.frame.AbsolutePosition
    local scale = self.frame.AbsoluteSize
    return mouse.X >= offset.X and mouse.X <= offset.X + scale.X
        and mouse.Y >= offset.Y and mouse.Y <= offset.Y + scale.Y
end

function MouseBasedJoystick:Destroy()
    
end

function MouseBasedJoystick:Enable()
    self.enabled = true
end

function MouseBasedJoystick:Disable()
    self.enabled = false
end

return MouseBasedJoystick