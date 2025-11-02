--[[ 
this script is used to boot up objects
TODO: Get rid of this
]]

local dir = require(game.ReplicatedStorage.Shared.mAS_Replicated.Directory)
local ProjectileController = require(dir.Modules.Core.ProjectileController)
local owned = {}
-- load order

return function()
    dir.Signals.FireProjectile:Connect(ProjectileController.Fire)
end