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


function TurretPlayerRoot:Destroy()
    self.maid:DoCleaning()
end

function TurretPlayerRoot.new(args, required)
    local uiHandler = _checkSetup(required)

    local self = setmetatable({}, TurretPlayerRoot)
    self.maid = dir.Maid.new()

    -- 1: set up base turret
    self.turretBase = TurretClientBase.new(args, required)

    -- 2: wrap player controls around base and provide init. args
    self.playerControls = TurretPlayerControls.new({
        controller = self.turretBase,
        joystick = args.Joystick,
    }, required)

    -- 3: set up UI handler with signals from base & joystick from player controls
    self.uiHandler = uiHandler.new({
        signals = self.turretBase.localSignals,
        joystickComponent = self.playerControls.joystick,
    }, required)

    -- flow of information:
    -- Input (playerControls) -> Logic (turretBase) -> UI (uiHandler)

    self.maid:GiveTasks(
        self.turretBase,
        self.playerControls,
        self.uiHandler
    )

    self.maid:GiveTask(RuS.RenderStepped:Connect(function(dt)
        self.turretBase:Update(dt)
        self.playerControls:Update(dt)

        local stickPos, stickRaw = self.playerControls.joystick:GetInput()
        self.uiHandler:Update(dt, {
            stickPos = stickPos,
            stickRaw = stickRaw,
            stickTime = self.playerControls.timeHoldingJoystick,
            stickMult = self.playerControls.rotationMult,
            lockedAxes = {
                x = self.playerControls.joystick.lockedX,
                y = self.playerControls.joystick.lockedY},
            
            rot = self.turretBase.TwoAxisRotator:GetRot(),
            orient = self.turretBase.OrientationReader:GetDirection(),
            pos = self.turretBase.OrientationReader:GetPos(),
            HUD = self.turretBase.OrientationReader:GetForwardPos(400),
            crosshair = self.turretBase.OrientationReader:GetForwardPos(4000),
            inCamera = self.turretBase.ForwardCamera 
                and self.playerControls.controller.ForwardCamera.enabled or false
        } :: UILoad)
    end))
    return self
end

export type UILoad = {
    stickPos: Vector2,
    stickRaw: Vector2,
    stickTime: number,
    stickMult: number,
    lockedAxes: {
        x: number,
        y: number
    },
    rot: Vector2,
    orient: {
        yaw: number,
        pitch: number,
        roll: number
    },
    pos: Vector3,
    crosshair: Vector3,
    inCamera: boolean,
}


return TurretPlayerRoot