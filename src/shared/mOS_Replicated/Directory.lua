local share =           game.ReplicatedStorage.Shared
local root =            script.Parent
local utility =         share.mOS_Utility

local modules =         root.Modules
local configs =         root.Configs
return {
    Shared =            root,
    Configs =           configs,
    Modules =           modules,
    Utility =           utility,

    ServerSignals =     require(modules.ServerSignals),
    Consts =            require(configs.Constants),
    Maid =              require(utility.Maid),
    Validator =         require(utility.Validator),
    Helpers =           require(utility.Helpers),
    NetUtils =          require(utility.NetUtils),
    Net =               require(utility.Net),
    Events =            require(modules.Events),
}
