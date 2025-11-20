--#region required
local dirServer = require(script.Parent.Parent.Parent.Directory)
local dir = dirServer.Main
--#endregion required
--[[
This is the purpose of this script.
]]
local RotatorReplServerHandler = {}
function RotatorReplServerHandler:Init()
	dir.Net:ConnectUnreliable(dir.Events.Unreliable.OnTurretWeldsUpdated, function(player, state, x, y)
		state:SetAttribute("X", x)
		state:SetAttribute("Y", y)
		dir.NetUtils:FireOtherClients(player, dir.Events.Unreliable.OnTurretWeldsUpdated, state)
	end)
end

return RotatorReplServerHandler
