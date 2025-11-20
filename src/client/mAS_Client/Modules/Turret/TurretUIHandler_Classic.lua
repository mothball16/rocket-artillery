--#region required
local dirClient = require(script.Parent.Parent.Parent.Directory)
local dir = dirClient.Main
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
the original UI from the 2022 version of this system
quarantine zone for spaghetti with meatballs code
]]
local template = dir.Assets.UI.TurretUI_Classic
local player = game.Players.LocalPlayer
local JOYSTICK_LERP_RATE = 0.5
local FOCUS_AXIS_COLOR = Color3.fromRGB(255, 50, 50)
local FREE_AXIS_COLOR = Color3.fromRGB(255,255,255)
local UI = {}
UI.__index = UI




local function _setupComponents(args, required)
    local canvas = template:Clone()
    local statsPanel = canvas:FindFirstChild("Stats")
    local orientPanel = canvas:FindFirstChild("Orient")
    local combatPanel = canvas:FindFirstChild("Combat")
    local aimPoint = canvas:FindFirstChild("AimPoint")
    local components = {
        stats = statsPanel,
        orient = orientPanel,
        combat = combatPanel,
        crosshair = aimPoint;
        zoom = statsPanel:FindFirstChild("Zoom");

        aiming = statsPanel.Aiming;
        joystick = statsPanel.Aiming.Stick;
        joystickRaw = statsPanel.Aiming.StickRaw;
        horizAxis = statsPanel.Aiming.Horizontal;
        vertAxis = statsPanel.Aiming.Vertical;

        joystickControlFrame = canvas:FindFirstChild("ControlFrame");
    }

    args.joystickComponent:SetFrame(components.joystickControlFrame)
    return canvas, components
end

local function _checkSetup(args)
    
end

function UI.new(args, required)
    local self = setmetatable({
        maid = dir.Maid.new();
        joystickPos = Vector2.new();
    }, UI)
    self.canvas, self.components = _setupComponents(args, required)
    self.canvas.Parent = player.PlayerGui
    self.maid:GiveTask(self.canvas)
    
    self:SetupConnections(args.signals)
    return self
end


function UI:SetupStatic(labels)
    self.components["combat"].Title.Text = labels.title
end


local function Lerp(a, b, t)
	return a + (b - a) * t
end

function UI:SetupConnections(signals)
    self.maid:GiveTask(signals.OnFire:Connect(function()
        print("fired")
    end))

    self.maid:GiveTask(signals.OnSalvoIntervalModified:Connect(function(salvoAmount)
	    self.components.combat.Quantity.Text = "QTY: " .. salvoAmount
    end))

    self.maid:GiveTask(signals.OnTimedIntervalModified:Connect(function(timeDelay)
        self.components.combat.Interval.Text = "INT: " .. timeDelay .. "s"
    end))

    self.maid:GiveTask(signals.OnRangeFinderToggled:Connect(function(toggle)
        
    end))
end

function UI:GetRequired()
    return self.canvas:FindFirstChild("RARequired")
end

function UI:Update(dt, state)
    -- joystick lerp
    local lerpFac = math.min(JOYSTICK_LERP_RATE * dt * 60, 1)
    self.joystickPos = Vector2.new((1 + state.stickPos.X)/2, (1 + state.stickPos.Y)/2)
    self.joystickRaw = Vector2.new((1 + state.stickRaw.X)/2, (1 + state.stickRaw.Y)/2)

    self.components.joystick.Position = UDim2.fromScale(
        Lerp(self.components.joystick.Position.X.Scale, self.joystickPos.X, lerpFac),
        Lerp(self.components.joystick.Position.Y.Scale, self.joystickPos.Y, lerpFac)
    )

    self.components.joystickRaw.Position = UDim2.fromScale(
        Lerp(self.components.joystickRaw.Position.X.Scale, self.joystickRaw.X, lerpFac),
        Lerp(self.components.joystickRaw.Position.Y.Scale, self.joystickRaw.Y, lerpFac)
    )

    self.components.joystickRaw.BackgroundTransparency = (state.lockedAxes.x or state.lockedAxes.y)
        and 0.8 or 0.5
    -- stats update
    self.components["stats"].Deflection.Text =
        "DFL: (" .. math.round((180 - state.orient.yaw) % 360) .. "°G) " .. math.round(state.rot.X) .. "° L"
	self.components["stats"].Elevation.Text = 
        "ELV: (".. math.round(state.orient.pitch) .. "°G) " .. math.round(state.rot.Y) .. "° L"
	self.components["stats"].Altitude.Text =
        "ALT: " .. math.round(state.pos.Y) .. " ft"
    self.components["stats"].Coords.Text = "COORDS: [" .. math.round(state.pos.X) .. "," .. math.round(state.pos.Z) .. "]"
    
    -- crosshair update
    local crosshairPos, onScreen = game.Workspace.CurrentCamera:WorldToScreenPoint(state.crosshair)


    self.components["crosshair"].Position = UDim2.new(0,crosshairPos.X,0,crosshairPos.Y)
    self.components["crosshair"].Visible = onScreen

    self.components["vertAxis"].BackgroundColor3 = state.lockedAxes.x
        and FOCUS_AXIS_COLOR or FREE_AXIS_COLOR
    self.components["horizAxis"].BackgroundColor3 = state.lockedAxes.y
        and FOCUS_AXIS_COLOR or FREE_AXIS_COLOR

    
end

function UI:Destroy()
    self.maid:DoCleaning()
end


return UI