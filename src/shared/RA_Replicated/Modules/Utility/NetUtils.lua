local NetUtils = {}
local modules = game.ReplicatedStorage.Shared.RA_Replicated.Modules
local Constants = require(modules.Constants)
local ObjectRegistry = require(modules.Core.ObjectRegistry)
local validator = require(modules.Utility.Validator).new(script.Name)

function NetUtils:ExecuteClient(tbl, main, required)
    print(tbl, main, required)
    for _, v in pairs(tbl) do
        if v["ExecuteClient"] then
            v:ExecuteClient(main, required)
        else
            v:Execute(main, required)
        end
    end
end

function NetUtils:ExecuteServer(tbl, main, required)
    for _, v in pairs(tbl) do
        if v["ExecuteServer"] then
            v:ExecuteServer(main, required)
        else
            v:Execute(main, required)
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
return NetUtils