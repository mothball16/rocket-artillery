--[[
loads every dependency at the start for ease of access, roblox caches this so it shouldn't
introduce any significant overhead
]]
local repl = game
        :WaitForChild("ReplicatedStorage")
        :WaitForChild("Shared")
        :WaitForChild("RA_Replicated")
local modules = repl:WaitForChild("Modules")
local assets = repl:WaitForChild("Assets")
local configs = repl:WaitForChild("Configs")
local utility = modules:WaitForChild("Utility")

local refs = {
    Shared = repl,
    Configs = configs,
    Modules = modules,
    Assets = assets,
    Utility = utility,
    Signals = require(repl:WaitForChild("Signals")),
    ServerSignals = require(repl:WaitForChild("ServerSignals")),
    Consts = require(modules:WaitForChild("Constants")),
    Maid = require(utility:WaitForChild("Maid")),
    FallbackConfig = require(utility:WaitForChild("FallbackConfig")),
    Validator = require(utility:WaitForChild("Validator")),
    Helpers = require(utility:WaitForChild("Helpers")),
    NetUtils = require(utility:WaitForChild("NetUtils")),
    Net = require(utility:WaitForChild("Net")),
    Events = require(repl:WaitForChild("Events")),
}

return refs