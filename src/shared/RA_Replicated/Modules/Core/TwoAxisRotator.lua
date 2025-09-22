local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local maid = require(dir.Modules.Utility.Maid)
local conf = require(dir.Modules.Utility.FallbackConfig)
local logger = require(dir.Modules.Utility.Logger)
local net, evts = dir.GetNetwork()
local WeldsUpdated = net:UnreliableRemoteEvent(evts.OnTurretWeldsUpdated)

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

local module = {}
module.__index = module

function module.new(args, state, rotMotor, pitchMotor)
    assert(rotMotor.ClassName == "ManualWeld", "(RA) twoaxisrotator setup fail: rotMotor isn't a ManualWeld")
    assert(pitchMotor.ClassName == "ManualWeld", "(RA) twoaxisrotator setup fail: pitchMotor isn't a ManualWeld")
    local self = {}
    self.maid = maid.new()
    self.config = conf.new(args, fallbacks)
    self.state = state
    self.rotMotor = rotMotor
    self.pitchMotor = pitchMotor
    self.enabled = true
    self.tick = 0
    -- we want to sync our client rots with the server rots here
    self.curX = self.state:GetAttribute("X")
    self.curY = self.state:GetAttribute("Y")

    -- TBA
    self.targetX = self.curX
    self.targetY = self.curY

    setmetatable(self, module)

    self.maid:GiveTask(RuS.RenderStepped:Connect(function(dt)
        self:Update(dt)
    end))

    self:UpdateWelds(self.curX, self.curY)
    logger.Print("twoAxisRotator loaded")
    return self
end

function module:UpdateWelds(x, y)
    self.rotMotor.C1 = CFrame.Angles(0,math.rad(x),0)
    self.pitchMotor.C1 = CFrame.Angles(0,0,-math.rad(y))
    if self.tick > WELD_UPDATE_THROTTLE then
        WeldsUpdated:FireServer(self.state, x, y)
        self.tick = 0
    end
end
-- TODO: logic for input should be moved out!!! this module should really only be rotating stuff - how we decide to rotate it should be decided elsewhere
function module:Update(dt)
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

function module:SetEnable(on)
    self.enabled = on
end

function module:SetTarget(x, y)
    self.targetX = x;
    self.targetY = y;
end

function module:SetTargetRelative(x, y)
    self.targetX = self.curX + x;
    self.targetY = self.curY + y;
end

function module:Destroy()
    self.maid:DoCleaning()
end



return module
