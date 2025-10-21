--[[
conventions:
client -> server: Request<...>
server -> client: On<...>
]]

return {
    Reliable = {
        -- object management
        OnInitialize = "OnInitialize",
        OnDestroy = "OnDestroy",

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

    };
    Unreliable = {
        -- turret weld stuff
        OnTurretWeldsUpdated = "OnTurretWeldsUpdated",
        OnParticlePlayed = "OnParticlePlayed",

        -- projectile replication
        OnProjectileUpdated = "OnProjectileUpdated",
        RequestProjectileUpdate = "RequestProjectileUpdate",

    }
}