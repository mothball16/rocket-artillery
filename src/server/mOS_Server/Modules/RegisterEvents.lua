local share = game.ReplicatedStorage.Shared
local dir = require(share.mOS_Replicated.Directory)
local validator = dir.Validator.new(script.Name)
return function()
    for _, inst in pairs(share:GetChildren()) do
        if not inst:HasTag(dir.Consts.FOLDER_IDENT_TAG_NAME) then continue end

        for _, scr in pairs(inst:GetDescendants()) do
            if scr:IsA("ModuleScript") and scr.Name == "Events" then
                local events = require(scr)
                validator:Exists(events.Reliable, "reliable table of auto-loading event script ")
                validator:Exists(events.Unreliable, "unreliable table of auto-loading event script")
                for _, v in pairs(events.Reliable) do
                    dir.Net:RemoteEvent(v)
                end
                for _, v in pairs(events.Unreliable) do
                    dir.Net:UnreliableRemoteEvent(v)
                end
                warn("loaded events : )")
            end
        end
        
    end
end
