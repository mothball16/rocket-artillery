-- replicates effects with a single FXActivator that swaps configs on call
-- the whole OOP thing with effects is just to package the FXActivator across
-- scripts so i mean i guess this works lol

local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local FXActivator = require(script.Parent.FXActivator)

return function()
    dir.Net:ConnectUnreliable(dir.Events.Unreliable.OnParticlePlayed,
    function(config, ...)
        FXActivator:ExecuteOnClient(config, ...)
    end)
end