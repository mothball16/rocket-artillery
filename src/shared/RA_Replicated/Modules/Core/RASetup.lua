
local RASetup = {}

function RASetup.SetupSeat(seat)
    seat.ChildAdded:Connect(function(child)
        if child.Name == "SeatWeld" then
            local human = child.part1.Parent:FindFirstChild("Humanoid")
            if human ~= nil then
                local clone = script.Parent.TurretControl:Clone()
                clone.Required.Value = script.Parent.Parent
                clone.Parent = game.Players:GetPlayerFromCharacter(human.Parent).PlayerGui
            end
        end
    end)

    seat.ChildRemoved:Connect(function(child)
        if child.Name == "SeatWeld" then
            local human = child.part1.Parent:FindFirstChild("Humanoid")
            if human ~= nil then
                game.Players:GetPlayerFromCharacter(human.Parent).PlayerGui:FindFirstChild("TurretControl"):Destroy()
            end
        end
    end)
end

return RASetup