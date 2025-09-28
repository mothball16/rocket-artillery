--#region required
local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
stores all created objects for lookup/communication
90% of the usecase for this is just being able to communicate between client and server controllers
important: this should not be storing objects of other clients because that would just be messy and
and indicate bad design
]]
local objects = {}
local ObjRegistry = {}

-- obj here is just the metatable holding everything together
function ObjRegistry:Register(obj, required)
    local ident = validator:HasAttr(required, dir.Consts.OBJECT_IDENT_ATTR)
    if type(validator:Exists(obj.Destroy, "destroy method of obj")) ~= "function" then
        validator.Error("obj")
    end
    objects[ident] = obj
    return obj, required
end

function ObjRegistry:Deregister(required)
    local ident = validator:HasAttr(required, dir.Consts.OBJECT_IDENT_ATTR)
    objects[ident]:Destroy()
    objects[ident] = nil
end


return ObjRegistry