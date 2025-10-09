return {
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


    --[[
    DONT TOUCH THIS!! unless you for some reason have an attribute or object exactly named
    like any of these (why would you do that)
    ]]
    REPL_ID = "mAS_replId";
    ATTACH_WELD_NAME = "mAS_AttachPointWeld";
    OBJECT_IDENT_ATTR = "mAS_ObjectIdentifier";
    SEATED_INIT_TAG_NAME = "mAS_RunOnSeated";
    LAST_UPDATE_FIELD = "mAS_LastUpdate";
}
