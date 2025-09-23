local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local net, evts = dir.GetNetwork()
local OnSeated = net:RemoteEvent(evts.OnSeated)
local OnUnseated = net:RemoteEvent(evts.OnUnseated)
local RASetup = {}


function RASetup.SetupTurret(required)
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

return RASetup