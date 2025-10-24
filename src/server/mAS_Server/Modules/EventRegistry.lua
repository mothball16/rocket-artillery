local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)

local function InitEvents()
	for _, v in pairs(dir.Events.Reliable) do
		dir.Net:RemoteEvent(v)
	end
	for _, v in pairs(dir.Events.Unreliable) do
		dir.Net:UnreliableRemoteEvent(v)
	end
end

return function()
	InitEvents()
end