local Debris = game:GetService("Debris")

local NetUtils = {}
local utils = script.Parent
local core = utils.Parent.mOS_Replicated

local Consts = require(core.Configs.Constants)
local ObjectRegistry = require(core.Modules.ObjectManagement.ObjectRegistry)

local Net = require(utils.Net)
local validator = require(utils.Validator).new(script.Name)

--[[
provides an easier way to interact across client/server
TODO: There are some things that shouldn't really be here that are here.
Move out: GetId, GetObject
]]
local events = {}

function NetUtils:ExecuteOnClient(tbl, ...)
    for _, command in pairs(tbl) do
        if command.func["ExecuteOnClient"] then
            command.func:ExecuteOnClient(command.data or {}, ...)
        else
            command.func:Execute(command.data or {}, ...)
        end
    end
end

function NetUtils:ExecuteOnServer(plr, tbl, ...)
    for _, command in pairs(tbl) do
        if command.func["ExecuteOnServer"] then
            command.func:ExecuteOnServer(plr, command.data or {}, ...)
        else
            command.func:Execute(command.data or {}, ...)
        end
    end
end

function NetUtils:GetId(required)
    return required:GetAttribute(Consts.OBJECT_IDENT_ATTR)
end

function NetUtils:GetObject(id)
    local object = ObjectRegistry:Get(id)
    if not object then
        validator:Warn("object of id " .. id .. "doesn't exist on the server.")
        return nil
    end
    return object
end

function NetUtils:FireOtherClients(plr, eventName, ...)

    local event = validator:Exists(self:GetEvent(eventName), "event: ".. tostring(eventName))
    for _, v in pairs(game.Players:GetChildren()) do
        if v == plr and not Consts.REPL_TO_ORIGINAL_CLIENT then continue end
        event:FireClient(v, ...)
    end
end

function NetUtils:FireClient(plr, eventName, ...)
    local event = validator:Exists(self:GetEvent(eventName), "event: ".. tostring(eventName))
    event:FireClient(plr, ...)
end

function NetUtils:GetEvent(name)
    if not events[name] then
        for _, v in pairs(Net:GetEvents()) do
            local evt = string.match(v.Name, "/(.*)")
            if v:IsA("UnreliableRemoteEvent") then
                events[evt] = Net:UnreliableRemoteEvent(evt)
            elseif v:IsA("RemoteEvent") then
                events[evt] = Net:RemoteEvent(evt)
            end
        end
    end
    return events[name]
end

return NetUtils