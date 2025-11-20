local bootstrapper = {}
local dirClient = require(script.Parent.Directory)
local dir = dirClient.Main
local loader = require(dir.Utility.Loader)
local modules = script.Parent.Modules
local ProjectileRegistry = require(dir.Modules.Projectile.ProjectileRegistry)
local ProjectileController = require(dir.Modules.Projectile.ProjectileController)

function bootstrapper:Init()
    ProjectileRegistry:Init()
    ProjectileController:Init()
    loader.SpawnAll(loader.LoadDescendants(modules), "Init")
end

return bootstrapper