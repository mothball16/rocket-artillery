local moduleFolder = script.Parent.Modules
local modules = {}
for _, module in pairs(moduleFolder:GetDescendants()) do
    if not module:IsA("ModuleScript") then continue end
    modules[module.Name] = require(module)
end
local beginTime = os.clock()
warn("(ServerBootstrapper) beginning mAS server load...")

modules["MakeIgnoreListIfNotExisting"]()        

-- immediately load, essential to other thingys
modules["EventRegistry"]()

-- sets up object initialization
modules["ObjectBootstrapper"]()

-- should load at the end
modules["ServerHandlerInitializer"]()

-- irrelevant to other modules
modules["ProjectileManager"]()

local endTime = os.clock()
warn("(ServerBootstrapper) mAS server fully loaded with no issues in ".. (endTime - beginTime) .. "sec.")       