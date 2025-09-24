-- Used to make sure that if something is wrong, it fails immediately with context.
-- This will not perform checks outside of Studio for performance reasons.
-- You can also not use this to reduce a negligible amount of overhead.

local devMode = game:GetService("RunService"):IsStudio()
local Validator = {}
Validator.__index = Validator

function Validator.new(caller)
    local self = setmetatable({
        ["caller"] = caller
    }, Validator)
    return self
end


function Validator:FailHead()
    return "(" .. self.caller .. ") validation fail: "
end

function Validator:HasAttr(obj, attrib)
    local val = obj:GetAttribute(attrib)
    if devMode then
        assert(val, self:FailHead() .. "attribute " .. attrib .. " doesn't exist on obj " .. obj.Name)
    end
    return val
end

function Validator:Exists(obj, from)
    if devMode then
        local err = (self:FailHead() .. "obj" .. (from or "") .. " doesn't exist")
        assert(obj and obj.Parent, err)
    end
    return obj
end

function Validator:IsOfClass(obj, class)
    if devMode and self:Exists(obj, "of intended class " .. class) then
        assert(obj:IsA(class), self:FailHead() .. " obj " .. obj.Name .. " is not of class " .. class)
    end
    return obj
end

function Validator:ValueIsOfClass(obj, class)
    if devMode then
        local value = self:Exists(obj, "of intended class " .. class).Value
        assert(value and self:IsOfClass(value, class), class, self:FailHead() .. " obj value of " .. obj.Name .. " is not of class " .. class)
    end
    return obj.Value
end

return Validator