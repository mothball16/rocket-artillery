-- TODO: directory shouldnt worry about the directory of the repl. folder. should probably just give a link to the repl. directory to use there

local share =           game.ReplicatedStorage.Shared
local repl =            share.mOS_Replicated
local utility =         share.mOS_Utility

local root =            script.Parent
local mOS =             root.Parent.mOS_Client
local modules =         repl.Modules


return {
    mOS =               mOS,
    Repl =              repl,
    Root =              root,
    Modules =           modules,
    Utility =           utility,
    Maid =              require(utility.Maid),
    Validator =         require(utility.Validator),
    Helpers =           require(utility.Helpers),
    NetUtils =          require(utility.NetUtils),
    Net =               require(utility.Net),
    Events =            require(repl.Modules.Events),
}
