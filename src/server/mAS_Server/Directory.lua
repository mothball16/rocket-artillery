-- TODO: directory shouldnt worry about the directory of the repl. folder. should probably just give a link to the repl. directory to use there

local share =           game.ReplicatedStorage.Shared
local repl =            share.mAS_Replicated
local utility =         share.mOS_Utility

local root =            script.Parent
local mOS =             root.Parent.mOS_Server
local modules =         repl.Modules
local assets =          repl.Assets
local configs =         repl.Configs

return {
    mOS =               mOS,
    Repl =              repl,
    Root =              root,
    Configs =           configs,
    Modules =           modules,
    Assets =            assets,
    Utility =           utility,
    Consts =            require(modules.Constants),
    Maid =              require(utility.Maid),
    Validator =         require(utility.Validator),
    Helpers =           require(utility.Helpers),
    NetUtils =          require(utility.NetUtils),
    Net =               require(utility.Net),
    Events =            require(repl.Events),
    Keybinds =          require(configs.Keybinds),
}
