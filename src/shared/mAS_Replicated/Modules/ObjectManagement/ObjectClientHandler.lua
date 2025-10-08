--[[ 
this script is used to boot up objects
]]
local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local objectInitializer = require(dir.Modules.ObjectManagement.ObjectInitializer).new("LocalController")
local owned = {}
-- load order


return function()
    dir.Net:Connect(dir.Events.Reliable.OnInitialize, function(required)
        print("yo?")
        if owned[required] then return end
        print("yo?2")
        owned[required] = objectInitializer:Execute(required)
    end)

    dir.Net:Connect(dir.Events.Reliable.OnDestroy, function(required)
        if owned[required] then
            owned[required].destroy()
            owned[required] = nil
        end
    end)
end