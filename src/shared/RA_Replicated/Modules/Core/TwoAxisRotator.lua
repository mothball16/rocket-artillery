local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local maid = require(dir.Modules.Utility.Maid)
local conf = require(dir.Modules.Utility.FallbackConfig)

local RuS = game.GetService("RunService")
local camera = game.Workspace.CurrentCamera
local mouse = game.Players.LocalPlayer.GetMouse()

local fallbacks = {
    rotMin = -90,
    rotMax = 90,
    rotSpeed = 1,
    rotLimited = false,

    pitchMax = 90,
    pitchMin = 0,
    pitchSpeed = 1,
}

local module = {}
module.__index = module

function module.new(args, state, rotMotor, pitchMotor)
    assert(rotMotor.ClassName == "Motor6D", "rotMotor isn't a motor6d")
    assert(pitchMotor.ClassName == "Motor6D", "pitchMotor isn't a motor6d")
    local self = {}
    self.maid = maid.new()
    self.config = conf.new(args, fallbacks)
    self.state = state
    self.rotMotor = rotMotor
    self.pitchMotor = pitchMotor
    self.enabled = true

    setmetatable(self, module)

    self.maid:GiveTask(RuS.RenderStepped:Connect(function(dt)
        self:Update(dt)
    end))

    return self
end

function module:Update(dt)
    local delta = dt * 60
    if self.enabled then
        local res = camera.ViewportSize - Vector2.new(0,36)
        local xRatio = math.clamp(3 * (mouse.X/res.X) - 1.5, -1, 1)
        local yRatio = math.clamp(3 * (mouse.Y/res.Y) - 1.5, -1, 1)
        local curX, curY = self.state:GetAttribute("X"), self.state:GetAttribute("Y")

        local rotSpeed = self.config:Get("rotSpeed")
        local rotLimited = self.config:Get("rotLimited")
        local rotTooLow = curX + xRatio * rotSpeed < self.config:Get("rotMin")
        local rotTooHigh = curX + xRatio * rotSpeed > self.config:Get("rotMax")

        if not(rotLimited or rotTooLow or rotTooHigh) then
            self.state:SetAttribute("X",curX + (xRatio * rotSpeed * delta))
            self.rotMotor.Pivot.C1 *= CFrame.Angles(0,math.rad(xRatio * rotSpeed),0)
        end

        local pitchSpeed = self.config:Get("pitchSpeed")
        local pitchTooLow = curY - yRatio * pitchSpeed < self.config:Get("pitchMin")
        local pitchTooHigh = curY - yRatio * pitchSpeed > self.config:Get("pitchMax")

        if not(pitchTooLow or pitchTooHigh) then
            self.state:SetAttribute("Y", curY + (yRatio * pitchSpeed * delta))
            self.pitchMotor.Pivot.C1 *= CFrame.Angles(math.rad(yRatio * pitchSpeed),0,0)
        end
        
    end
end

function module:Destroy()
    self.maid:DoCleaning()
end

return module
