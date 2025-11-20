--[[
loads every dependency at the start for ease of access, roblox caches this so it shouldn't
introduce any significant overhead
]]

local share =           game.ReplicatedStorage.Shared
local root =            script.Parent
local modules =         root.Modules
local utility =         share.mOS_Utility
local assets =          root.Assets
local configs =         root.Configs

return {
    Shared =            share,
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
    Events =            require(root.Events),
    Keybinds =          require(configs.Keybinds),
}
