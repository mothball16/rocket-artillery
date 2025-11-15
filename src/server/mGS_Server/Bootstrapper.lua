local bootstrapper = {}
local modules = script.Parent.Modules
local ObjectiveManager = require(modules.Core.ObjectiveManager)
function bootstrapper:Init()
    ObjectiveManager()
end

return bootstrapper