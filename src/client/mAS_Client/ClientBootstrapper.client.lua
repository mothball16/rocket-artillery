local moduleFolder = script.Parent.Modules
local modules = {}
for _, module in pairs(moduleFolder:GetDescendants()) do
    if not module:IsA("ModuleScript") then continue end
    modules[module.Name] = require(module)
end
local beginTime = os.clock()
warn("(ClientBootstrapper) beginning mAS client load...")

modules["ClientEventDump_ToRemove"]()

-- should load at the end
modules["ClientHandlerInitializer"]()

modules["ProjectileReplHandler"]()

local endTime = os.clock()
warn("(ClientBootstrapper) mAS client fully loaded with no issues in ".. (endTime - beginTime) .. "sec.")