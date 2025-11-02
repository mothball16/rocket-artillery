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

        -- fx
        OnParticlePlayed = "OnParticlePlayed",
        OnParticleCreated = "OnParticleCreated",
    };
    Unreliable = {
        -- turret weld stuff
        OnTurretWeldsUpdated = "OnTurretWeldsUpdated",


        -- projectile replication
        OnProjectileUpdated = "OnProjectileUpdated",
        RequestProjectileUpdate = "RequestProjectileUpdate",
    }
}