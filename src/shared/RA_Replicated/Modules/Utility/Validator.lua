-- Used to make sure that if something is wrong, it fails immediately with context.
-- This will not perform checks outside of Studio for performance reasons.
-- You can also not use this to reduce a negligible amount of overhead.

local devMode = game:GetService("RunService"):IsStudio()
local Validator = {}
Validator.__index = Validator

-- (caller)
function Validator.new(caller)
    local self = setmetatable({
        ["caller"] = caller
    }, Validator)
    return self
end


-- ()
function Validator:FailHead()
    return "(" .. (self.caller or "unspecified") .. ") validation fail: "
end

-- (obj, attrib)
function Validator:HasAttr(obj, attrib)
    print(obj)
    local val = self:Exists(obj, "obj searching for attribute " .. attrib):GetAttribute(attrib)
    if devMode then
        assert(val, self:FailHead() .. "attribute " .. attrib .. " doesn't exist on obj " .. obj.Name)
    end
    return val
end

-- (obj, from)
function Validator:Exists(obj, from)
    if devMode then
        local err = (self:FailHead() .. (from or "") .. " doesn't exist")
        assert(obj, err)
    end
    return obj
end

-- (obj, class)
function Validator:IsOfClass(obj, class)
    if devMode and self:Exists(obj, "obj of intended class " .. class) then
        assert(obj:IsA(class), self:FailHead() .. " obj " .. obj.Name .. " is not of class " .. class)
    end
    return obj
end

-- (obj, class)
function Validator:ValueIsOfClass(obj, class)
    if devMode then
        local value = self:Exists(obj, "of intended class " .. class).Value
        assert(value and self:IsOfClass(value, class), class, self:FailHead() .. " obj value of " .. obj.Name .. " is not of class " .. class)
    end
    return obj.Value
end

-- (msg)
function Validator:Warn(msg)
    warn(self:FailHead() .. msg)
end

-- (msg)
function Validator:Error(msg)
    error(self:FailHead() .. msg)
end
return Validator