local bootstrapper = {}
local dir = require(script.Parent.Directory)
local modules = script.Parent.Modules
local ProjectileRegistry = require(dir.Repl.Modules.Projectile.ProjectileRegistry)
local GeneralReplHandler = require(modules.GeneralReplHandler)
local ProjectileReplHandler = require(modules.Projectile.ProjectileReplHandler)
local ProjectileEventListener = require(modules.Projectile.ProjectileEventListener)
local RotatorReplHandler = require(modules.Turret.RotatorReplHandler)
function bootstrapper:Init()
    ProjectileRegistry:Init()
    
    GeneralReplHandler()
    RotatorReplHandler()
    ProjectileReplHandler()
    ProjectileEventListener()
end

return bootstrapper