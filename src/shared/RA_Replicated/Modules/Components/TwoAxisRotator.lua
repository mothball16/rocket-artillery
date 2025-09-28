local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local validator = dir.Validator.new(script.Name)
local WeldsUpdated = dir.Net:UnreliableRemoteEvent(dir.Events.OnTurretWeldsUpdated)

local RuS = game:GetService("RunService")
local camera = game.Workspace.CurrentCamera
local mouse = game.Players.LocalPlayer:GetMouse()

local WELD_UPDATE_THROTTLE = 0.1

local fallbacks = {
    rotMin = -90,
    rotMax = 90,
    rotSpeed = 1,
    rotLimited = false,

    pitchMax = 90,
    pitchMin = 0,
    pitchSpeed = 1,
}

local TwoAxisRotator = {}
TwoAxisRotator.__index = TwoAxisRotator

local function _checkSetup(required)
    local rotMotor = validator:ValueIsOfClass(
        required:FindFirstChild("RotMotor"), "ManualWeld")
    local pitchMotor = validator:ValueIsOfClass(
        required:FindFirstChild("PitchMotor"), "ManualWeld")
    local state = validator:IsOfClass(
        required:FindFirstChild("TwoAxisRotatorState"), "Folder")
    return rotMotor, pitchMotor, state
end

-- (args, required)
function TwoAxisRotator.new(args, required)
    local rotMotor, pitchMotor, state = _checkSetup(required)
    local self = setmetatable({
        maid = dir.Maid.new(),
        config = dir.FallbackConfig.new(args, fallbacks),
        state = state,
        rotMotor = rotMotor,
        pitchMotor = pitchMotor,
        enabled = true,
        tick = 0,
        curX = state:GetAttribute("X"),
        curY = state:GetAttribute("Y"),
        targetX = state:GetAttribute("X"),
        targetY = state:GetAttribute("Y"),
    }, TwoAxisRotator)

    self.maid:GiveTask(RuS.RenderStepped:Connect(function(dt)
        self:Update(dt)
    end))

    self:UpdateWelds(self.curX, self.curY)
    return self
end

-- (x, y)
function TwoAxisRotator:UpdateWelds(x, y)
    self.rotMotor.C1 = CFrame.Angles(0,math.rad(x),0)
    self.pitchMotor.C1 = CFrame.Angles(0,0,-math.rad(y))
    if self.tick > WELD_UPDATE_THROTTLE then
        WeldsUpdated:FireServer(self.state, x, y)
        self.tick = 0
    end
end
-- TODO: logic for input should be moved out!!! this module should really only be rotating stuff - how we decide to rotate it should be decided elsewhere
function TwoAxisRotator:Update(dt)
    self.tick += dt
    local adjustForDt = dt * 60
    if self.enabled then
        local res = camera.ViewportSize - Vector2.new(0,36)
        local xRatio = math.clamp(3 * (mouse.X/res.X) - 1.5, -1, 1)
        local yRatio = math.clamp(3 * (mouse.Y/res.Y) - 1.5, -1, 1)

        local rotSpeed = self.config:Get("rotSpeed")
        local rotLimited = self.config:Get("rotLimited")
        self.curX += xRatio * rotSpeed * adjustForDt
        if rotLimited then
            self.curX = math.clamp(self.curX, self.config:Get("rotMin"), self.config:Get("rotMax"))
        end

        local pitchSpeed = self.config:Get("pitchSpeed")
        self.curY = math.clamp(self.curY - (yRatio * pitchSpeed * adjustForDt), self.config:Get("pitchMin"), self.config:Get("pitchMax"))
        
        self:UpdateWelds(self.curX, self.curY)
    end
end

-- (on)
function TwoAxisRotator:SetEnable(on)
    self.enabled = on
end

-- (x, y)
function TwoAxisRotator:SetTarget(x, y)
    self.targetX = x;
    self.targetY = y;
end

-- (x, y)
function TwoAxisRotator:SetTargetRelative(x, y)
    self.targetX = self.curX + x;
    self.targetY = self.curY + y;
end

-- ()
function TwoAxisRotator:Destroy()
    self.maid:DoCleaning()
end



return TwoAxisRotator
