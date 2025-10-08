local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)

return function()
    dir.Net:ConnectUnreliable(dir.Events.Unreliable.OnTurretWeldsUpdated,
        function(state)
        if not state then return end
        local rot = state.RotMotor.Value
        local pitch = state.PitchMotor.Value
        if not rot and pitch then return end

        rot.C1 = CFrame.Angles(0,math.rad(state:GetAttribute("X")),0)
        pitch.C1 = CFrame.Angles(0,0,-math.rad(state:GetAttribute("Y")))
    end)
end