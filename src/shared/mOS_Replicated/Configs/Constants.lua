return {
    OBJECT_IDENT_ATTR = "mOS_ObjectIdentifier";
    LAZY_LOAD_SERVER_CONTROLLER_ATTR = "mOS_LazyLoadServerController";

    FOLDER_IDENT_TAG_NAME = "mOS_FrameworkFolder";
    LOAD_ORDER_TAG_NAME = "mOS_BootstrapperLoadOrder";

    SPAWN_INIT_TAG_NAME = "mOS_RunOnSpawn";
    SEATED_INIT_TAG_NAME = "mOS_RunOnSeated";
    TOOL_INIT_TAG_NAME = "mOS_RunOnEquipped"; -- [!] under this tag, there is a delay because object initialization is done from the server. there is no way around this yet
    REPL_TO_ORIGINAL_CLIENT = false;
}