local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local validator = dir.Validator.new(script.Name)
local WeldsUpdated = dir.Net:UnreliableRemoteEvent(dir.Events.Unreliable.OnTurretWeldsUpdated)

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
        dir = Vector2.new(0,0),
        enabled = true,
        tick = 0,
        curX = state:GetAttribute("X"),
        curY = state:GetAttribute("Y"),
        targetX = state:GetAttribute("X"),
        targetY = state:GetAttribute("Y"),
    }, TwoAxisRotator)

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
        local rotSpeed = math.rad(self.config:Get("rotSpeed"))
        local rotLimited = self.config:Get("rotLimited")
        self.curX += self.dir.X * rotSpeed * adjustForDt
        if rotLimited then
            self.curX = math.clamp(self.curX, self.config:Get("rotMin"), self.config:Get("rotMax"))
        end

        local pitchSpeed = math.rad(self.config:Get("pitchSpeed"))
        self.curY = math.clamp(self.curY - (self.dir.Y * pitchSpeed * adjustForDt), self.config:Get("pitchMin"), self.config:Get("pitchMax"))
        
        self:UpdateWelds(self.curX, self.curY)
    end
end

-- (on)
function TwoAxisRotator:SetEnable(on)
    self.enabled = on
end

function TwoAxisRotator:SetIntent(newDir)
    self.dir = newDir
end

--[[
-- (x, y)
function TwoAxisRotator:SetTarget(x, y)
    self.targetX = x;
    self.targetY = y;
end

-- (x, y)
function TwoAxisRotator:SetTargetRelative(x, y)
    self.targetX = self.curX + x;
    self.targetY = self.curY + y;
end]]

-- ()
function TwoAxisRotator:Destroy()
    self.maid:DoCleaning()
end



return TwoAxisRotator
