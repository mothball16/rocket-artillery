--#region required
local dir = require(game.ReplicatedStorage.Shared.mAS_Replicated.Directory)
local validator = dir.Validator.new(script.Name)
local TS = game:GetService("TweenService")
--#endregion required
--[[
stateless module for projectile replication from the client
]]

local ReplicateOrientationHandler = {}

function ReplicateOrientationHandler:Create(prefab, args)
    validator:Exists(prefab.PrimaryPart)
    local obj = prefab:Clone()
    obj.Parent = game.Workspace.IgnoreList
    obj:SetPrimaryPartCFrame(args.cf)
    obj.PrimaryPart.Anchored = true
    return obj
end

-- later we should interp. this
function ReplicateOrientationHandler:Update(object, state)
    if not object or not state.cf then return false end
    local lastUpd = state[dir.Consts.LAST_UPDATE_FIELD .. "_last"]
    if not lastUpd then
        object:SetPrimaryPartCFrame(state.cf)
        return true
    end
    local tweenTime = state[dir.Consts.LAST_UPDATE_FIELD] - lastUpd
    TS:Create(object.PrimaryPart,TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = state.cf}):Play()
    return true
end


function ReplicateOrientationHandler:Destroy(object)
    object:Destroy()
end
return ReplicateOrientationHandler