local bootstrapper = {}
local modules = script.Parent.Modules
local ClientHandlerInitializer = require(modules.ClientHandlerInitializer)

function bootstrapper:Init()
    ClientHandlerInitializer()
end

return bootstrapper