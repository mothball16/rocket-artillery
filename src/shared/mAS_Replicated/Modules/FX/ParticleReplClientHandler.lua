--#region requires
local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local FXActivator = require(script.Parent.FXActivator)
local FXCreator = require(script.Parent.FXCreator)
--#endregion
--[[
picks up particle replication events and passes them over to the controllers
]]
return function()
    dir.Net:Connect(dir.Events.Reliable.OnParticlePlayed,
    function(config, ...)
        FXActivator:ExecuteOnClient(config, ...)
    end)
    dir.Net:Connect(dir.Events.Reliable.OnParticleCreated, function(config, ...)
        FXCreator:ExecuteOnClient(config, ...)
    end)
end