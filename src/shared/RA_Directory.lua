-- this might introduce some overhead but it cant be that bad right...

local repl = game:WaitForChild("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("RA_Replicated")
local server = game:WaitForChild("ServerScriptService"):WaitForChild("Server"):WaitForChild("RA_Server")
local client = game:WaitForChild("StarterPlayer"):WaitForChild("StarterPlayerScripts"):WaitForChild("Client"):WaitForChild("RA_Client")
local rsc = repl:WaitForChild("Resources")
local modules = repl:WaitForChild("Modules")
local assets = repl:WaitForChild("Assets")

local refs = {
    Shared = repl,
    Server = server,
    Client = client,
    Resources = rsc,
    Modules = modules,
    Assets = assets,
}

return refs