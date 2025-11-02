--#region required
local repl = script.Parent.Parent.Parent
local validator = require(repl.Parent.mOS_Utility.Validator).new(script.Name)
local consts = require(repl.Configs.Constants)
--#endregion required
--[[
stores all created objects for lookup/communication
90% of the usecase for this is just being able to communicate between client and server controllers
important: this should not be storing objects of other clients because that would just be messy and
and indicate bad design
]]
local objects = {}
local ObjectRegistry = {}

function ObjectRegistry:Get(id)
    return objects[id]
end
-- obj here is just the metatable holding everything together
function ObjectRegistry:Register(obj, required)
    local ident = validator:HasAttr(required, consts.OBJECT_IDENT_ATTR)
    if type(validator:Exists(obj.Destroy, "destroy method of obj")) ~= "function" then
        validator.Error("obj metatable needs a destroy method")
    end

    if objects[ident] then
        warn("object of GUID " ..  ident 
        .. " already exists in table. Object not added, returning old one.")
        return objects[ident], required
    end
    objects[ident] = obj
    return obj, required
end

function ObjectRegistry:Deregister(required)
    local ident = validator:HasAttr(required, consts.OBJECT_IDENT_ATTR)
    objects[ident]:Destroy()
    objects[ident] = nil
end

function ObjectRegistry:WasRegistered(required)    
    local ident = validator:HasAttr(required, consts.OBJECT_IDENT_ATTR)
    return objects[ident] ~= nil
end

return ObjectRegistry