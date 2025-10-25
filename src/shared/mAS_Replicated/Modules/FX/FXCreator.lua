--#region required
local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
builds and fires particles from a position/cframe. this is less flexible than FXActivator,
since it needs to be pre-cached particles, but it allows for firing particles without
the object being on the server
]]

local controller = {}
local particles = dir.Assets.Particles
local fallbacks = {
    ["useFX"] = "RocketMediumExplosion",
    ["playFor"] = 0.25,
}


function controller:ExecuteOnClient(config, args)
    config = dir.Helpers:TableOverwrite(fallbacks, config)
    local template = dir.Assets.Particles:FindFirstChild(config["useFX"])
    if not template then
        warn("(FXCreator) no FX found for fx arg " .. config["useFX"])
        return
    end
    local fxClone = template:Clone()
    fxClone.Parent = game.Workspace.IgnoreList
    fxClone.CanCollide = false
    fxClone.CanQuery = false
    fxClone.Transparency = 1
    fxClone.Anchored = true
    fxClone.CFrame = args.cf

    local maxEmitLength = 0
    for _, fx in pairs(fxClone:GetChildren()) do
		local isEmitter = fx:IsA("ParticleEmitter") or fx:IsA("Trail") or fx:IsA("Beam") or fx:IsA("Smoke")
		local emitLength = fx:GetAttribute("PlayFor") or config["playFor"]
		maxEmitLength = math.max(maxEmitLength, emitLength)
        if isEmitter then
            fx.Enabled = true
            task.delay(emitLength, function()
                fx.Enabled = false
            end)
        elseif fx:IsA("Sound") then
            fx.TimePosition = 0
            fx:Play()
        end
	end

    game.Debris:AddItem(fxClone, 30 + maxEmitLength)
end

function controller:ExecuteOnServer(plr, config, args)
    config = dir.Helpers:TableOverwrite(fallbacks, config)
    dir.NetUtils:FireOtherClients(plr, dir.Events.Reliable.OnParticleCreated, config, args)
end

return controller
