--#region requires
local dir = require(game.ReplicatedStorage.Shared.mAS_Replicated.Directory)
local validator = dir.Validator.new(script.Name)
local FX = require(dir.Modules.FX.FX)
local GoShake = require(dir.Modules.OnHit.GoShake)
--#endregion
--[[
picks up shit that just re-routes the client event back to the behavior module.
to find behavior look in the behavior module itself, this just wires it up
]]


local function RouteSingle(evtName, behavior)
    validator:Exists(behavior.ExecuteOnClient, "ExecuteOnClient func of behavior")
    dir.Net:Connect(evtName, function(config, ...)
        behavior:ExecuteOnClient(config, ...)
    end)
end

local function Route(connections)
    for _, cmd in pairs(connections) do
        RouteSingle(cmd[1], cmd[2])
    end
end

return function()
    Route({
        {dir.Events.Reliable.OnParticleCreated, FX.Create},
        {dir.Events.Reliable.OnParticlePlayed, FX.Activate},
        {dir.Events.Reliable.OnShake, GoShake},
    })
end