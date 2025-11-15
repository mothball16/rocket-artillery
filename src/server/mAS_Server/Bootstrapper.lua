local bootstrapper = {}
local dir = require(script.Parent.Directory)
local modules = script.Parent.Modules
local ProjectileManager = require(modules.Projectile.ProjectileManager)
local ProjectileRegistry = require(dir.Repl.Modules.Projectile.ProjectileRegistry)
function bootstrapper:Init()
    ProjectileRegistry:Init()
    ProjectileManager()
end

return bootstrapper