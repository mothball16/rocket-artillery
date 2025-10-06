--#region required
local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
--#endregion required
--[[
this initializes all singleton event handlers (scripts named ...ClientHandler)
server handlers shouldn't require any dependencies realistically and are
entirely detached from the structure so this is just a shortcut so i dont have to go
back and put them here every time i make a new one for client/server comm.
]]
return function()
    for _, handler in pairs(dir.Modules:GetDescendants()) do
        if handler:IsA("ModuleScript") and string.find(handler.Name, "ClientHandler") then
            print("loading " .. handler.Name .. "...")
            require(handler)()
        end
    end
end