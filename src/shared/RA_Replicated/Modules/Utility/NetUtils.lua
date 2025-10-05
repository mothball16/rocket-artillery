--[[
provides an easier way to interact across client/server
]]

local NetUtils = {}
local modules = game.ReplicatedStorage.Shared.RA_Replicated.Modules
local Constants = require(modules.Constants)
local ObjectRegistry = require(modules.ObjectManagement.ObjectRegistry)
local validator = require(modules.Utility.Validator).new(script.Name)

--[[ (do this later)
local net = require(modules.Utility.Net)
local events = require(modules.Parent.Events)
local remotes = {}

for _, v in pairs(require(modules.Parent.Events)) do
    
end]]

function NetUtils:ExecuteOnClient(tbl, ...)
    for _, v in pairs(tbl) do
        if v["ExecuteOnClient"] then
            v:ExecuteOnClient(...)
        else
            v:Execute(...)
        end
    end
end

function NetUtils:ExecuteOnServer(plr, tbl, ...)
    for _, v in pairs(tbl) do
        if v["ExecuteOnServer"] then
            v:ExecuteOnServer(plr, ...)
        else
            v:Execute(...)
        end
    end
end

function NetUtils:GetId(required)
    return required:GetAttribute(Constants.OBJECT_IDENT_ATTR)
end

function NetUtils:GetObject(id)
    local object = ObjectRegistry:Get(id)
    if not object then
        validator:Warn("object of id " .. id .. "doesn't exist on the server.")
        return nil
    end
    return object
end

function NetUtils:FireOtherClients(plr, event, ...)
    validator:Exists(event["FireClient"], "FireClient function of event")
    for _, v in pairs(game.Players:GetChildren()) do
        if v == plr then continue end
        print(event, ...)
        event:FireClient(v, ...)
    end
end

return NetUtils