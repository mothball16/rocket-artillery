--[[ 
this script is used to boot up objects
]]

local dirClient = require(script.Parent.Parent.Parent.Directory)
local dir = dirClient.Main

local objectInitializer = require(game.ReplicatedStorage.Shared.mOS_Replicated.Modules.ObjectManagement.ObjectInitializer).new("LocalController")
local owned = {}
-- load order

return function()
    dir.Net:Connect(dir.Events.Reliable.OnInitialize, function(required)
        if owned[required] then return end
        owned[required] = objectInitializer:Execute(required)
    end)

    dir.Net:Connect(dir.Events.Reliable.OnDestroy, function(required)
        if owned[required] then
            owned[required].destroy()
            owned[required] = nil
        end
    end)
end