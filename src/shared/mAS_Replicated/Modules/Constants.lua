return {
    --[[
    whether projectiles can damage your own team
    ]]
    FRIENDLY_FIRE = true;

    --[[
    what FOV the player returns to upon unscripting the camera
    ]]
    FOV_DEFAULT = 70;

    --[[
    how long the projectile replicator waits before falling back to destroy the projectile,
    regardless of its current state (in case of sloppy netcode causing a leak)
    ]]
    MAX_PROJECTILE_LIFETIME = 60;
    --[[
    the delay between each report from the client to the server about where the projectile is
    higher throttle = less network load but choppier trajectory for other clients
    ]]
    REPLICATION_THROTTLE = 0.2;



    REPL_ID = "mAS_ReplId";
    DESTROYABLE_JOINT_ATTR = "mAS_Destroyable";

    SELECTOR_INTERACT_ATTR = "mAS_SelectorInteractionPoint";
    AMMO_TYPE = "mAS_AmmoType";
    ATTACH_WELD_NAME = "mAS_AttachPointWeld";
    OBJECT_IDENT_ATTR = "mAS_ObjectIdentifier";
    LAST_UPDATE_FIELD = "mAS_LastUpdate";
}
