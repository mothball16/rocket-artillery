local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local objectInitializer = require(dir.Modules.ObjectManagement.ObjectInitializer).new("ServerController")

local objects = {}


return function()
    dir.ServerSignals.InitObject:Connect(function(required)
        objects[required] = objectInitializer:Execute(required)
        print("shimureishon")
    end)

    dir.ServerSignals.DestroyObject:Connect(function(required)
        if not objects[required] then
            warn("object " .. (required and required.Name or "<not found>") .. " wasn't found in ObjectLifetimeListener")
        end
        objects[required].destroy()
        objects[required] = nil
    end)    
end
