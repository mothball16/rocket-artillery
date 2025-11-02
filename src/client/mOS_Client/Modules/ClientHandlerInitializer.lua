--#region required
local share = game.ReplicatedStorage.Shared
local dir = require(share.mOS_Replicated.Directory)
--#endregion required
--[[
this initializes all singleton event handlers (scripts named ...ClientHandler)
server handlers shouldn't require any dependencies realistically and are
entirely detached from the structure so this is just a shortcut so i dont have to go
back and put them here every time i make a new one for client/server comm.
]]
return function()
    warn("WARNING: this should be removed eventually. this patttern is kinda dumb, move client handlers to the client folder")

    for _, folder in pairs(share:GetChildren()) do
        if folder:HasTag(dir.Consts.FOLDER_IDENT_TAG_NAME) then
            for _, handler in pairs(folder:GetDescendants()) do
                if handler:IsA("ModuleScript") and string.find(handler.Name, "ClientHandler") then
                    warn("loading " .. handler.Name .. "...")
                    require(handler)()
                end
            end
        end
    end
end
