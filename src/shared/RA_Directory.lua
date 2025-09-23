-- this might introduce some overhead but it cant be that bad right...

local repl = game:WaitForChild("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("RA_Replicated")
local modules = repl:WaitForChild("Modules")
local assets = repl:WaitForChild("Assets")
local configs = repl:WaitForChild("Configs")
local events = repl:WaitForChild("Events")
local net = modules.Utility:WaitForChild("Net")
local signals = repl:WaitForChild("Signals")
local refs = {
    Shared = repl,
    Configs = configs,
    Modules = modules,
    Assets = assets,
    Signals = signals,
}

-- short-cut for getting events and network at the top of a script, since you will almost 
-- never use one without the other
function refs.GetNetwork()
    return require(net), require(events)
end

return refs