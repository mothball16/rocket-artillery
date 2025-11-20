--[[ 
this script is used to boot up objects
TODO: Get rid of this
]]

local dirClient = require(script.Parent.Parent.Parent.Directory)
local dir = dirClient.Main
local ProjectileController = require(dir.Modules.Projectile.ProjectileController)
local ProjectileEventListener = {}


function ProjectileEventListener:Init()
    dirClient.Signals.FireProjectile:Connect(ProjectileController.Fire)
    dirClient.Signals.FireProjectile:Connect(function()
        print("yuh uh")
    end)
end

return ProjectileEventListener