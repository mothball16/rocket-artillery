--#region required
local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local validator = dir.Validator.new(script.Name)
local ObjectRegistry = require(dir.Modules.ObjectManagement.ObjectRegistry)
--#endregion required
--[[
This runs the initialization process and returns the object + relevant connections.
]]

local ObjectInitializer = {}
ObjectInitializer.__index = ObjectInitializer

function ObjectInitializer.new(controller)
    local self = setmetatable({}, ObjectInitializer)
    self.controller = controller
    return self
end
---initializes and registers obj. according to prefab/controller link
---@param required Folder the folder containing all components and references
---@return table the object and the corresponding method to destroy it
function ObjectInitializer:Execute(required)
    if ObjectRegistry:WasRegistered(required) then
        validator:Log("Object of GUID " .. dir.NetUtils:GetId(required) .. " was already registered.")
        return
    end
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
            ObjectRegistry:Deregister(required)
        end
        required.Destroying:Connect(DestroyObj)
        return {
            object = ObjectRegistry:Register(obj, required),
            destroy = DestroyObj,
        }
    else
       warn("object attempted to be initialized, but initroot was incomplete/missing") 
    end
    return nil
end

return ObjectInitializer