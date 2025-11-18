--[[
conventions:
client -> server: Request<...>
server -> client: On<...>
]]

return {
    Reliable = {
        -- projecitle replication
        OnProjectileDestroyed = "OnProjectileDestroyed",
        RequestProjectileDestroy = "RequestProjectileDestroy",

        OnProjectileCreated = "OnProjectileCreated",
        RequestProjectileCreate = "RequestProjectileCreate",

        OnProjectileHit = "OnProjectileHit",
        RequestProjectileHit = "RequestProjectileHit",

        -- attachment management
        RequestAttachmentDetach = "RequestAttachmentDetach",
        RequestAttachmentUse = "RequestAttachmentUse",
        RequestAttachmentAttach = "RequestAttachmentAttach",
        OnAttachStateModified = "OnAttachStateModified", -- (required), calls clients to refresh the attachstate. this would only be connected to within clientcontrollers that need the information

        -- fx
        OnParticlePlayed = "OnParticlePlayed",
        OnParticleCreated = "OnParticleCreated",

        -- shake
        OnShake = "OnShake",
    };
    Unreliable = {
        -- turret weld stuff
        OnTurretWeldsUpdated = "OnTurretWeldsUpdated",


        -- projectile replication
        OnProjectileUpdated = "OnProjectileUpdated",
        RequestProjectileUpdate = "RequestProjectileUpdate",
    }
}