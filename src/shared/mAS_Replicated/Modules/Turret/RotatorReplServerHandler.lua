--#region required
local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
--#endregion required
--[[
This is the purpose of this script.
]]
return function()
	dir.Net:ConnectUnreliable(dir.Events.Unreliable.OnTurretWeldsUpdated, function(player, state, x, y)
		state:SetAttribute("X", x)
		state:SetAttribute("Y", y)
		dir.NetUtils:FireOtherClients(player, dir.Events.Unreliable.OnTurretWeldsUpdated, state)
	end)
end
