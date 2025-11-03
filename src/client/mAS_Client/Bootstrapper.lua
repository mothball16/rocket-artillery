local bootstrapper = {}
local modules = script.Parent.Modules
local GeneralReplHandler = require(modules.GeneralReplHandler)
local ProjectileReplHandler = require(modules.ProjectileReplHandler)
local ProjectileEventListener = require(modules.ProjectileEventListener)

function bootstrapper:Init()
    GeneralReplHandler()
    ProjectileReplHandler()
    ProjectileEventListener()
end

return bootstrapper