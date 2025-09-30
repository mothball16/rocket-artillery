--#region required
local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local validator = dir.Validator.new(script.Name)
local ObjRegistry = require(dir.Modules.Core.ObjRegistry)
--#endregion required
--[[
This runs the initialization process and returns the object + relevant connections.
]]

local component = {}
component.__index = component

function component.new(controller)
    local self = setmetatable({}, component)
    self.controller = controller
    return self
end

function component:Execute(required)
    local entryPoint = validator:Exists(
        required:FindFirstChild("InitRoot"), "InitRoot of seat activator")

    local controllerRef = entryPoint:FindFirstChild(self.controller)
    if controllerRef and controllerRef.Value then
        local controller = require(controllerRef.Value)

        local prefab = require(validator:Exists(
            entryPoint:FindFirstChild("Prefab"), "prefab ObjectValue").Value)
        validator:Exists(controller["new"], "new function of obj. controller")
            local obj = controller.new(prefab, required)
        -- attach a bunch of GC stuff, since this is a huge risk for memory leaks
        local function DestroyObj()
            ObjRegistry:Deregister(required)
        end
        required.Destroying:Connect(DestroyObj)
        return {
            object = ObjRegistry:Register(obj, required),
            destroy = DestroyObj,
        }
    end
    return nil
end

return component