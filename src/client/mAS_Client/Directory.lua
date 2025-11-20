local share =           game.ReplicatedStorage.Shared
local repl =            share.mAS_Replicated

local root =            script.Parent
local mOS =             root.Parent.mOS_Client


return {
    Signals =           require(share.mAS_Replicated.Modules.Core.Signals),
    Main =              require(share.mAS_Replicated.Directory),
    mOS =               mOS,
    Repl =              repl,
    Root =              root,
}
