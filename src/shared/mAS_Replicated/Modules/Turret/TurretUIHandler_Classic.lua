--#region required
local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
the original UI from the 2022 version of this system
]]
local template = dir.Assets.UI.TurretUI_Classic
local player = game.Players.LocalPlayer
local JOYSTICK_LERP_RATE = 0.5
local UI = {}
UI.__index = UI

local function _setupComponents(args, required)
    local canvas = template:Clone()
    local statsPanel = canvas:FindFirstChild("Stats")
    local orientPanel = canvas:FindFirstChild("Orient")
    local combatPanel = canvas:FindFirstChild("Combat")
    local components = {
        stats = statsPanel,
        orient = orientPanel,
        combat = combatPanel,
        joystick = statsPanel.Aiming.Stick;
        zoom = statsPanel:FindFirstChild("Zoom");
    }
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

function UI:OLD(state)
    --[[
	local look = required:FindFirstChild("AimPoint").CFrame.lookVector
	local heading = math.atan2(look.x, look.z)
	heading = math.deg(heading)
	hud.Stats.Deflection.Text = "DFL: " .. roundNumber(-heading+180,1)
	hud.Stats.Elevation.Text = "ELV: " ..  roundNumber(required:FindFirstChild("AimPoint").Orientation.X,1)
	hud.Orient.Turret.Rotation = -(required:FindFirstChild("AimPoint").Orientation.Y - required:FindFirstChild("Base").Orientation.Y) - 45
	hud.Combat.Title.Text = config.vehicleName
	if canTurn then
		hud.Combat.Lock.Text = "FREE"
		hud.Combat.Lock.TextColor3 = Color3.fromRGB(200,255,200)
	else
		hud.Combat.Lock.Text = "LOCK"
		hud.Combat.Lock.TextColor3 = Color3.fromRGB(255,200,200)
	end
	hud.Stats.Zoom.Bar.Size = UDim2.new(1,0,1-((camera.FieldOfView-config.minFOV)/(70-config.minFOV)),0)
	local ignore = required:WaitForChild("Vehicle").Value:GetDescendants()
	local pointDist = 1000
	local hit, pos = workspace:FindPartOnRayWithIgnoreList(Ray.new(required:WaitForChild("AimPoint").Position, required:WaitForChild("AimPoint").CFrame.lookVector * pointDist), ignore);

	if hit then
		pointDist = (required:WaitForChild("AimPoint").Position - pos).Magnitude
	end
	local crosshairPos = game.Workspace.CurrentCamera:WorldToScreenPoint(required:WaitForChild("AimPoint").CFrame * CFrame.new(0,0,-pointDist).Position)

	hud:FindFirstChild("AimPoint").Position = UDim2.new(0,crosshairPos.X,0,crosshairPos.Y)
	hud.Stats.Altitude.Text = "ALT: " .. math.floor(required:FindFirstChild("Base").Position.Y+0.5)
	hud.Stats.Coords.Text = "COORDS: [" .. math.floor(required:FindFirstChild("Base").Position.X+0.5)  .. ", " ..  math.floor(required:FindFirstChild("Base").Position.Z+0.5) .. "]" 
	hud.Combat.Interval.Text = "INT: " .. config.fireInts[fireIndex]
	hud.Combat.Quantity.Text = "QTY: " .. config.fireQts[salvoIndex]
	hud.Combat.Loaded.Text = ready
	hud.Combat.Rockets.Text = count]]

end

function UI:Destroy()
    self.maid:DoCleaning()
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

function UI:Update(dt, state)
    local lerpFac = math.min(JOYSTICK_LERP_RATE * dt * 60, 1)
    self.joystickPos = Vector2.new((1 + state.stickPos.X)/2, (1 + state.stickPos.Y)/2)
    self.components.joystick.Position = UDim2.fromScale(
        Lerp(self.components.joystick.Position.X.Scale, self.joystickPos.X, lerpFac),
        Lerp(self.components.joystick.Position.Y.Scale, self.joystickPos.Y, lerpFac)
    )

    self.components["stats"].Deflection.Text =
        "DFL: (" .. math.round((180 - state.orient.yaw) % 360) .. "°G) " .. math.round(state.rot.X) .. "° L"
	self.components["stats"].Elevation.Text = 
        "ELV: (".. math.round(state.orient.pitch) .. "°G) " .. math.round(state.rot.Y) .. "° L"
	self.components["stats"].Altitude.Text =
        "ALT: " .. math.round(state.height) .. " ft"
end

return UI