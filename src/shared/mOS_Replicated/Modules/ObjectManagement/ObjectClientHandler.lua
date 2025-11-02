--[[ 
this script is used to boot up objects
]]

local dir = require(script.Parent.Parent.Parent.Directory)

local objectInitializer = require(script.Parent.ObjectInitializer).new("LocalController")
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