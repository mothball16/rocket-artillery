--#region required
local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
sets/unsets the camera to the forward lookvector of a part
]]
local camera = game.Workspace.CurrentCamera 
local ForwardCamera = {}
ForwardCamera.__index = ForwardCamera

local fallbacks = {
    maxFOV = 70;
    minFOV = 70;

}

local function _checkSetup(required)
    return validator:ValueIsOfClass(required:FindFirstChild("Camera"), "BasePart")
end
function ForwardCamera.new(args, required)
    local cam = _checkSetup(required)
    local self = setmetatable({}, ForwardCamera)
    self.config = dir.FallbackConfig.new(args, fallbacks)
    self.cam = cam
    self.enabled = false

    self.FOV = self.config:Get("maxFOV")
    return self
end

function ForwardCamera:Enable()
    camera.CameraType = Enum.CameraType.Scriptable
    self.enabled = true
    self:Update()
end

function ForwardCamera:Update()
    camera.CFrame = self.cam.CFrame
    camera.FieldOfView = self.FOV
end

function ForwardCamera:Disable()
    camera.CameraType = Enum.CameraType.Custom
    camera.FieldOfView = dir.Consts.FOV_DEFAULT
    self.enabled = false
end

function ForwardCamera:SetFOV(fov)
    self.FOV = math.clamp(fov, self.config:Get("minFOV"), self.config:Get("maxFOV"))
end

function ForwardCamera:Destroy()
    self:Disable()
end 
return ForwardCamera