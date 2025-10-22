
local NetUtils = {}
local repl = game.ReplicatedStorage.Shared.mAS_Replicated
local modules = repl.Modules
local Constants = require(modules.Constants)
local ObjectRegistry = require(modules.ObjectManagement.ObjectRegistry)
local Net = require(modules.Utility.Net)
local Events = require(repl.Events)
local validator = require(modules.Utility.Validator).new(script.Name)

--[[
provides an easier way to interact across client/server
TODO: There are some things that shouldn't really be here that are here.
Move out: GetId, GetObject
]]
local events = {}

for _, v in pairs(Events.Reliable) do
    events[v] = Net:RemoteEvent(v)
end
for _, v in pairs(Events.Unreliable) do
    if events[v] then
        error("An unreliable and a reliable event shouldn't be connected to the same name!")
    end
    events[v] = Net:UnreliableRemoteEvent(v)
end


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

function NetUtils:FireOtherClients(plr, eventName, ...)

    local event = validator:Exists(events[eventName], "event: ".. tostring(eventName))
    for _, v in pairs(game.Players:GetChildren()) do
        if v == plr then continue end
        event:FireClient(v, ...)
    end
end

return NetUtils