--#region required
local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
the original UI from the 2022 version of this system
]]
local canvas = script.Canvas.Value
local player = game.Players.LocalPlayer

local UI = {}
UI.__index = UI

local function _checkSetup(required)
    
end

function UI.new(args, required)
    local self = setmetatable({}, UI)
    self.maid = dir.Maid.new()
    self.canvas = canvas:Clone()
    self.canvas.Parent = player.PlayerGui
    self.maid:GiveTask(self.canvas)
    return self
end

function UI:Update(state)
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

return UI