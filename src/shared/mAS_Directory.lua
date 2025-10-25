--[[
loads every dependency at the start for ease of access, roblox caches this so it shouldn't
introduce any significant overhead
]]

-- hacky thing to deal with scripts loading before the entire hierarchy is implemented
game:WaitForChild("ReplicatedStorage")
    :WaitForChild("Shared")
    :WaitForChild("mAS_Replicated")
    :WaitForChild("Modules")
local repl = game.ReplicatedStorage.Shared.mAS_Replicated
local modules =         repl.Modules
local utility =         modules.Utility
local assets =          repl.Assets
local configs =         repl.Configs

return {
    Shared =            repl,
    Configs =           configs,
    Modules =           modules,
    Assets =            assets,
    Utility =           utility,
    Signals =           require(repl.Signals),
    ServerSignals =     require(repl.ServerSignals),
    Consts =            require(modules.Constants),
    Maid =              require(utility.Maid),
    Validator =         require(utility.Validator),
    Helpers =           require(utility.Helpers),
    NetUtils =          require(utility.NetUtils),
    Net =               require(utility.Net),
    Events =            require(repl.Events),
    Keybinds =          require(configs.Keybinds),
}
