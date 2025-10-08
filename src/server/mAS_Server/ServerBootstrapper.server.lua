local moduleFolder = script.Parent.Modules
local modules = {}
for _, module in pairs(moduleFolder:GetChildren()) do
    modules[module.Name] = require(module)
end
local beginTime = os.clock()
warn("(ServerBootstrapper) beginning mAS server load...")
-- immediately load, essential to other thingys
modules["EventRegistry"]()

-- sets up object initialization
modules["ObjectBootstrapper"]()

-- should load at the end
modules["ServerHandlerInitializer"]()

local endTime = os.clock()
warn("(ServerBootstrapper) mAS server fully loaded with no issues in ".. (endTime - beginTime) .. "sec.")