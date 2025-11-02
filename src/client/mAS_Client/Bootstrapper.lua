local bootstrapper = {}
local modules = script.Parent.Modules
local ProjectileReplHandler = require(modules.ProjectileReplHandler)
local ProjectileEventListener = require(modules.ProjectileEventListener)
function bootstrapper:Init()
    ProjectileReplHandler()
    ProjectileEventListener()
end

return bootstrapper