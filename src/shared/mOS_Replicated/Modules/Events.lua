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
    };
    Unreliable = {};
}