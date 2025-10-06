-- replicates effects with a single particleactivator that swaps configs on call
-- the whole OOP thing with effects is just to package the particleactivator across
-- scripts so i mean i guess this works lol

local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local ParticleActivator = require(script.Parent.ParticleActivator)

return function()
    dir.Net:ConnectUnreliable(dir.Events.Unreliable.OnParticlePlayed,
    function(config, ...)
        print(config, ...)
        ParticleActivator.config:Overwrite(config)
        ParticleActivator:ExecuteOnClient(...)
    end)
end