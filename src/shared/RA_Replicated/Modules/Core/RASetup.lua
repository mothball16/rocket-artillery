local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local net, evts = dir.GetNetwork()
local OnSeated = net:RemoteEvent(evts.OnSeated)
local OnUnseated = net:RemoteEvent(evts.OnUnseated)
local RASetup = {}


local function GetPlayerFromSeatInteraction(child)
    if child.Name ~= "SeatWeld" then return end
    local human = child.part1.Parent:FindFirstChild("Humanoid")
    if not human then return nil end
    local player = game.Players:GetPlayerFromCharacter(human.Parent)
    return player
end

function RASetup.SetupTurret(required)
    local seat = required.ControlSeat.Value
    seat.ChildAdded:Connect(function(child)
        local player = GetPlayerFromSeatInteraction(child)
        if not player then return end
        OnSeated:FireClient(player, required)
        --[[
        local clone = script.ControllerUI.Value:Clone()
        clone.Parent = player.PlayerGui]]
    end)

    seat.ChildRemoved:Connect(function(child)
        local player = GetPlayerFromSeatInteraction(child)
        if not player then return end
        OnUnseated:FireClient(player, required)
        --[[
        player.PlayerGui:FindFirstChild(script.ControllerUI.Value.Name):Destroy()]]
    end)
end

return RASetup