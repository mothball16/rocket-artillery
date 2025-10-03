-- a collection of enums for the network so not everything is stringly typed
return {
    Reliable = {
        OnInitialize = "OnInitialize",
        OnDestroy = "OnDestroy",
        RequestAttachmentDetach = "RequestAttachmentDetach",
        RequestAttachmentUse = "RequestAttachmentUse",
        RequestAttachmentAttach = "RequestAttachmentAttach",
    };
    Unreliable = {
        OnTurretWeldsUpdated = "OnTurretWeldsUpdated",
    }
}