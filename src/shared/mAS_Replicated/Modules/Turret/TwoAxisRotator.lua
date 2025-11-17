local dir = require(script.Parent.Parent.Parent.Directory)
local validator = dir.Validator.new(script.Name)
local WeldsUpdated = dir.Net:UnreliableRemoteEvent(dir.Events.Unreliable.OnTurretWeldsUpdated)

local camera = game.Workspace.CurrentCamera
local mouse = game.Players.LocalPlayer:GetMouse()

local WELD_UPDATE_THROTTLE = 0.1
local AUDIO_ORIG_IDENTIFIER = "mAS_AudioOrigVolume"


local fallbacks = {
    rotMin = -90,
    rotMax = 90,
    rotSpeed = 1,
    rotLimited = false,

    maxStep = 0.5,

    pitchMax = 90,
    pitchMin = 0,
    pitchSpeed = 1,

    audioPitchMin = 0.8,
    audioPitchMax = 1,
    volumeMinThreshold = -0.05,
    volumeMaxThreshold = 0.25,
}

local TwoAxisRotator = {}
TwoAxisRotator.__index = TwoAxisRotator

local function _checkSetup(required)
    local state = validator:IsOfClass(
        required:FindFirstChild("TwoAxisRotatorState"), "Folder")
    local rotMotor = validator:ValueIsOfClass(
        state:FindFirstChild("RotMotor"), "ManualWeld")
    local pitchMotor = validator:ValueIsOfClass(
        state:FindFirstChild("PitchMotor"), "ManualWeld")
    local rotAudio = state:FindFirstChild("RotAudio") and state:FindFirstChild("RotAudio").Value or nil
    local pitchAudio = state:FindFirstChild("PitchAudio") and state:FindFirstChild("PitchAudio").Value or nil

    if not rotAudio:GetAttribute(AUDIO_ORIG_IDENTIFIER) then
        rotAudio:SetAttribute(AUDIO_ORIG_IDENTIFIER, rotAudio.Volume)
    end
    if not pitchAudio:GetAttribute(AUDIO_ORIG_IDENTIFIER) then
        pitchAudio:SetAttribute(AUDIO_ORIG_IDENTIFIER, pitchAudio.Volume)
    end
    return rotMotor, pitchMotor, state, rotAudio
end

-- (args, required)
function TwoAxisRotator.new(args, required)
    local rotMotor, pitchMotor, state, rotAudio = _checkSetup(required)
    local self = setmetatable({
        maid = dir.Maid.new(),
        config = dir.Helpers:TableOverwrite(fallbacks, args),
        state = state,
        rotMotor = rotMotor,
        pitchMotor = pitchMotor,
        rotAudio = rotAudio,
        dir = Vector2.new(0,0),
        dirIntent = Vector2.new(0,0),
        enabled = true,
        tick = 0,
        curX = state:GetAttribute("X"),
        curY = state:GetAttribute("Y"),
    }, TwoAxisRotator)

    self:UpdateWelds(self.curX, self.curY, true)
    return self
end

-- (x, y)
function TwoAxisRotator:UpdateWelds(x, y, replicate)
    self.rotMotor.C1 = CFrame.Angles(0,math.rad(x),0)
    self.pitchMotor.C1 = CFrame.Angles(0,0,-math.rad(y))
    if replicate and self.tick > WELD_UPDATE_THROTTLE then
        WeldsUpdated:FireServer(self.state, x, y)
        self.tick = 0
    end
end

function TwoAxisRotator:PlayHydraulics(audio: Sound, factor: number)
    
    local volume = math.map(math.clamp(factor, self.config.volumeMinThreshold,
        self.config.volumeMaxThreshold), self.config.volumeMinThreshold, self.config.volumeMaxThreshold, 0, audio:GetAttribute(AUDIO_ORIG_IDENTIFIER))
    local pitch = math.map(factor, 0, 1, self.config.audioPitchMin, self.config.audioPitchMax)
    audio.Volume = volume
    audio.PlaybackSpeed = pitch
    if not audio.Playing then
        audio:Play()
    end
end

function TwoAxisRotator:Update(dt)
    self.tick += dt
    local adjustForDt = dt * 60

    local dirDiff = self.dirIntent - self.dir
    local maxStepThisFrame = self.config.maxStep * dt
    self.dir += Vector2.new(math.clamp(dirDiff.X, -maxStepThisFrame, maxStepThisFrame), math.clamp(dirDiff.Y, -maxStepThisFrame, maxStepThisFrame))

    
    if self.enabled then
        local rotSpeed = math.rad(self.config["rotSpeed"])
        local rotLimited = self.config["rotLimited"]
        self.curX += self.dir.X * rotSpeed * adjustForDt
        if rotLimited then
            self.curX = math.clamp(self.curX, self.config["rotMin"], self.config["rotMax"])
        end
        self.curX %= 360
        local pitchSpeed = math.rad(self.config["pitchSpeed"])
        self.curY = math.clamp(self.curY - (self.dir.Y * pitchSpeed * adjustForDt), self.config["pitchMin"], self.config["pitchMax"])
        self:UpdateWelds(self.curX, self.curY, true)
    end
    if self.rotAudio then
        self:PlayHydraulics(self.rotAudio, math.abs(self.dir.X))
    end
    if self.pitchAudio then
        self:PlayHydraulics(self.pitchAudio, math.abs(self.dir.Y))
    end
end

-- (on)
function TwoAxisRotator:SetEnable(on)
    self.enabled = on
end

function TwoAxisRotator:SetIntent(newDir)
    self.dirIntent = newDir
end

function TwoAxisRotator:GetRot()
    return Vector2.new(self.curX, self.curY)
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
    if self.rotAudio and self.rotAudio.Playing then
        self.rotAudio:Stop()
    end
    self.maid:DoCleaning()
end



return TwoAxisRotator
