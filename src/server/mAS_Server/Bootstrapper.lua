local bootstrapper = {}
local dirServer = require(script.Parent.Directory)
local dir = dirServer.Main
local modules = script.Parent.Modules
local loader = require(dir.Utility.Loader)
local ProjectileRegistry = require(dir.Modules.Projectile.ProjectileRegistry)
local ProjectileController = require(dir.Modules.Projectile.ProjectileController)

function bootstrapper:Init()
    ProjectileRegistry:Init()
    ProjectileController:Init()
    loader.SpawnAll(loader.LoadDescendants(modules), "Init")
end

return bootstrapper