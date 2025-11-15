--#region required
local dir = require(game.ReplicatedStorage.Shared.mAS_Replicated.Directory)
local validator = dir.Validator.new(script.Name)
local TurretClientBase = require(script.Parent.TurretClientBase)
local TurretPlayerControls = require(script.Parent.TurretPlayerControls)
local RuS = game:GetService("RunService")
--#endregion required
--[[
initializes the turret systems in order & passes local dependencies down the line
]]

local TurretPlayerRoot = {}
TurretPlayerRoot.__index = TurretPlayerRoot

local function _checkSetup(required)
    local uiHandler = require(validator:ValueIsOfClass(required:FindFirstChild("UIHandler"), "ModuleScript"))
    validator:Exists(uiHandler.new, "constructor of UI handler")
    validator:Exists(uiHandler.Update, "update of UI handler")
    validator:Exists(uiHandler.SetupStatic, "static label initializer of UI handler")
    return uiHandler
end
function TurretPlayerRoot.new(args, required)
    local uiHandler = _checkSetup(required)

    local self = setmetatable({}, TurretPlayerRoot)
    self.maid = dir.Maid.new()

    self.turretBase = TurretClientBase.new(args, required)

    self.playerControls = TurretPlayerControls.new({
        controller = self.turretBase,
        Joystick = args.Joystick,
    }, required)

    self.uiHandler = uiHandler.new({
        signals = self.turretBase.localSignals,
        joystickComponent = self.playerControls.joystick,
    }, required)


    self.maid:GiveTasks(
        self.turretBase,
        self.playerControls,
        self.uiHandler
    )

    self.maid:GiveTask(RuS.RenderStepped:Connect(function(dt)
        self.turretBase:Update(dt)
        self.playerControls:Update(dt)

        self.uiHandler:Update(dt, {
            stickPos = self.playerControls.joystick:GetInput(),
            rot = self.turretBase.TwoAxisRotator:GetRot(),
            orient = self.turretBase.OrientationReader:GetDirection(),
            pos = self.turretBase.OrientationReader:GetPos(),
            crosshair = self.turretBase.OrientationReader:GetForwardPos(200),
            inCamera = self.turretBase.ForwardCamera 
                and self.playerControls.controller.ForwardCamera.enabled or false
        })
    end))
    return self
end

function TurretPlayerRoot:Destroy()
    self.maid:DoCleaning()
end

return TurretPlayerRoot