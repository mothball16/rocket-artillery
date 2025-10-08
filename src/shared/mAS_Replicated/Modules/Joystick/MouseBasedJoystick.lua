--#region required
local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
tracks ur mouse on-screen and maps it between -1, 1 on both axes
all joysticks should implement GetInput(), will be asserted on validation
]]
local plr = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local mouse = plr:GetMouse()

local fallbacks = {
    sens = 1;
    deadzone = Vector2.new(0.005,0.005);
}
local MouseBasedJoystick = {}
MouseBasedJoystick.__index = MouseBasedJoystick

local function _checkSetup(required)
    
end
function MouseBasedJoystick.new(args, required)
    local self = setmetatable({}, MouseBasedJoystick)
    self.config = dir.FallbackConfig.new(args, fallbacks)
    return self
end

function MouseBasedJoystick:GetInput()
    local sens = self.config:Get("sens")
    local deadzone = self.config:Get("deadzone") * sens
    local res = camera.ViewportSize - Vector2.new(0,116)
    local xRatio = math.clamp(2 * sens * (mouse.X/res.X) - sens, -1, 1)
    local yRatio = math.clamp(2 * sens * (mouse.Y/res.Y) - sens, -1, 1)
    if math.abs(xRatio) < deadzone.X then
        xRatio = 0
    end

    if math.abs(yRatio) < deadzone.Y then
        yRatio = 0
    end
    return Vector2.new(xRatio, yRatio)
end

function MouseBasedJoystick:Destroy()
    
end

return MouseBasedJoystick