local share =           game.ReplicatedStorage.Shared
local repl =            share.mOS_Replicated
local utility =         share.mOS_Utility

local root =            script.Parent
local mOS =             root.Parent.mOS_Client


return {
    mOS =               mOS,
    Repl =              repl,
    Root =              root,
    Utility =           utility,
    Main =              require(repl.Directory)
}
