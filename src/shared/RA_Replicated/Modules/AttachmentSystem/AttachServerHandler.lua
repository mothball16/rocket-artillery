local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local validator = dir.Validator.new(script.Name)
return function()
    dir.Net:Connect(dir.Events.Reliable.RequestAttachmentDetach, function(_, id, index)
        local obj = dir.NetUtils:GetObject(id)
        if not obj then return end
        local serverController = validator:Exists(
            obj.AttachServerController, "AttachServerController of turret id ".. id)

        serverController:DetachAt(index)
    end)

    dir.Net:Connect(dir.Events.Reliable.RequestAttachmentUse, function(_, id, index)
        local obj = dir.NetUtils:GetObject(id)
        if not obj then return end
        local serverController = validator:Exists(
            obj.AttachServerController, "AttachServerController of turret id ".. id)

        serverController:UseAt(index)
    end)
end