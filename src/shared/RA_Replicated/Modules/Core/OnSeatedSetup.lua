local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local OnSeatedSetup = {}
local OnSeated = dir.Net:RemoteEvent(dir.Events.OnSeated)
local OnUnseated = dir.Net:RemoteEvent(dir.Events.OnUnseated)
-- (required)
function OnSeatedSetup.ConnectControlSeat(required)
    local seat = required.ControlSeat.Value
    local lastOccupant
    seat:GetPropertyChangedSignal("Occupant"):Connect(function()
        local occupant = seat.Occupant
        if occupant then
            occupant = occupant.Parent
            local player = game.Players:GetPlayerFromCharacter(occupant)
            if player then
                OnSeated:FireClient(player, required)
            end
        else
            local player = game.Players:GetPlayerFromCharacter(lastOccupant)
            if player then
                OnUnseated:FireClient(player, required)
            end
        end
        lastOccupant = occupant
    end)
end

return OnSeatedSetup