local dir = require(script.Parent.Parent.Parent.Directory)
local validator = dir.Validator.new(script.Name)
return function()
    dir.Net:Connect(dir.Events.Reliable.RequestAttachmentDetach, function(plr, id, index)
        local obj = dir.NetUtils:GetObject(id)
        if not obj then return end
        local serverController = validator:Exists(
            obj.AttachServerController, "AttachServerController of turret id ".. id)

        serverController:DetachAt(plr, index)
    end)

    dir.Net:Connect(dir.Events.Reliable.RequestAttachmentUse, function(plr, id, index)
        local obj = dir.NetUtils:GetObject(id)
        if not obj then return end
        local serverController = validator:Exists(
            obj.AttachServerController, "AttachServerController of turret id ".. id)

        serverController:UseAt(plr, index)
    end)
end