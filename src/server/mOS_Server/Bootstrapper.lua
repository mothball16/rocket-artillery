local bootstrapper = {}
local modules = script.Parent.Modules
local RegisterEvents = require(modules.RegisterEvents)
local MakeIgnoreListIfNotExisting = require(modules.MakeIgnoreListIfNotExisting)
local ObjectBootstrapper = require(modules.ObjectBootstrapper)
local ObjectServerHandler = require(modules.ObjectServerHandler)
local ServerHandlerInitializer = require(modules.ServerHandlerInitializer)

function bootstrapper:Init()
    RegisterEvents()
    MakeIgnoreListIfNotExisting()
    ObjectBootstrapper()
    ObjectServerHandler()
    ServerHandlerInitializer()
end

return bootstrapper