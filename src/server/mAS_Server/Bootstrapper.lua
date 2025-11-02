local bootstrapper = {}
local modules = script.Parent.Modules
local ProjectileManager = require(modules.ProjectileManager)
function bootstrapper:Init()
    ProjectileManager()
end

return bootstrapper