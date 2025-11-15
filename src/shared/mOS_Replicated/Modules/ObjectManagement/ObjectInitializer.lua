--#region required
local dir = require(script.Parent.Parent.Parent.Directory)
local validator = dir.Validator.new(script.Name)
local ObjectRegistry = require(script.Parent.ObjectRegistry)
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
        required:FindFirstChild("InitRoot"), "InitRoot of activator")

    local controllerRef = entryPoint:FindFirstChild(self.controller)

    if not controllerRef then return end
    if controllerRef.Value then
        local controller = require(controllerRef.Value)
        local prefab = entryPoint:FindFirstChild("Prefab") and require(entryPoint:FindFirstChild("Prefab").Value) or {}
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
       warn("you are missing a value in the " .. controllerRef.Name) 
    end
    return nil
end

return ObjectInitializer