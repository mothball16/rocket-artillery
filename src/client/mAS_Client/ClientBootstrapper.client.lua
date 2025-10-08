local moduleFolder = script.Parent.Modules
local modules = {}
for _, module in pairs(moduleFolder:GetChildren()) do
    modules[module.Name] = require(module)
end
local beginTime = os.clock()
warn("(ClientBootstrapper) beginning mAS client load...")

modules["ClientEventDumpCauseIHaventFinishedThisYet"]()

-- should load at the end
modules["ClientHandlerInitializer"]()

local endTime = os.clock()
warn("(ClientBootstrapper) mAS client fully loaded with no issues in ".. (endTime - beginTime) .. "sec.")