local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local objectInitializer = require(dir.Modules.Core.ObjectInitializer).new("ServerController")

dir.ServerSignals.InitObject:Connect(function(required)
    objectInitializer:Execute(required)
end)

