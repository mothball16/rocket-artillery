--[[
conventions:
client -> server: Request<...>
server -> client: On<...>
]]

return {
    Reliable = {
        OnInitialize = "OnInitialize",
        OnDestroy = "OnDestroy",

        OnProjectileDestroyed = "OnProjectileDestroyed",
        RequestProjectileDestroy = "RequestProjectileDestroy",

        OnProjectileCreated = "OnProjectileCreated",
        RequestProjectileCreate = "RequestProjectileCreate",

        RequestAttachmentDetach = "RequestAttachmentDetach",
        RequestAttachmentUse = "RequestAttachmentUse",
        RequestAttachmentAttach = "RequestAttachmentAttach",

    };
    Unreliable = {
        OnTurretWeldsUpdated = "OnTurretWeldsUpdated",
        OnParticlePlayed = "OnParticlePlayed",

        OnProjectileUpdated = "OnProjectileUpdated",
        RequestProjectileUpdate = "RequestProjectileUpdate",

    }
}