--[[ 
this script is used to load any modules that will last for the entire
duration of play
]]

local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local ProjectileController = require(dir.Modules.Core.ProjectileController)
local ObjRegistry = require(dir.Modules.Core.ObjRegistry)
local owned = nil
-- load order

dir.Net:Connect(dir.Events.OnSeated, function(required)
    local entryPoint = dir.Validator:Exists(
        required:FindFirstChild("InitRoot"), "InitRoot of seat activator")
    local prefab = require(dir.Validator:Exists(
        entryPoint:FindFirstChild("Prefab"), "prefab ObjectValue").Value)
    local controller = require(dir.Validator:Exists(
        entryPoint:FindFirstChild("Controller"), "controller ObjectValue").Value)
    dir.Validator:Exists(controller["new"], "new function of obj. controller")

    local turret = controller.new(prefab, required)
    owned = {
        object = ObjRegistry:Register(turret, required),
        destroy = function() ObjRegistry:Deregister(required) end,
    }
end)

dir.Net:Connect(dir.Events.OnUnseated, function(required)
    if owned then
        owned.destroy()
    end
end)

dir.Net:ConnectUnreliable(dir.Events.OnTurretWeldsUpdated, function(state)

end)

dir.Signals.FireProjectile:Connect(ProjectileController.Fire)
