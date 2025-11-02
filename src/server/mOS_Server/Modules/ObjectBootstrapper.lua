--[[
    Sets up tagged objects and sends a request to build the object
    when initialization conditions meet.
]]

local dir = require(game.ReplicatedStorage.Shared.mOS_Replicated.Directory)
local HTTP = game:GetService("HttpService")
local CS = game:GetService("CollectionService")

local ServerSignals = dir.ServerSignals

local function Initialize(player, required)
    --[[
        this will initialize the server object only if it hasn't been created yet
        server objects should only be used if you need something to exist beyond the
        scope of the client that's essential to the object itself

        good (should use a server object): ammo rack state thats interactible on both 
        server/client, where the client needs to communicate to the server to specificlaly 
        act upon that object's specific ammo rack

        bad (should not use a server object): particle spawning, you can do this without
        a connection to the server object

        client object will be initialized below
    ]]
    dir.NetUtils:FireClient(player, dir.Events.Reliable.OnInitialize, required)
    ServerSignals.InitObject:Fire(required)
end

local function Destroy(player, required)
    --[[
        server objects don't explicitly destroy themselves here

        important: this means server objects are responsible for their own cleanup!!!
        you have to set up something on your servercontroller to do that or else there
        will be a memory leak

        client object will be de-initialized below
    ]]
    dir.NetUtils:FireClient(player, dir.Events.Reliable.OnDestroy, required)
end

local function AddSeatInitListener(required)
    required:SetAttribute(dir.Consts.OBJECT_IDENT_ATTR, HTTP:GenerateGUID())
    local seat = required.ControlSeat.Value
    local lastOccupant
    seat:GetPropertyChangedSignal("Occupant"):Connect(function()
        local occupant = seat.Occupant
        if occupant then
            occupant = occupant.Parent
            local player = game.Players:GetPlayerFromCharacter(occupant)
            if player then
                Initialize(player, required)
            end
        else
            if not lastOccupant or not lastOccupant.Parent then
                warn("occupant missing?")
                return
            end
            local player = game.Players:GetPlayerFromCharacter(lastOccupant)
            if player then
                Destroy(player, required)
            end
        end
        lastOccupant = occupant
    end)
end

return function()
    for _, v in pairs(CS:GetTagged(dir.Consts.SEATED_INIT_TAG_NAME)) do
        AddSeatInitListener(v)
    end

    CS:GetInstanceAddedSignal(dir.Consts.SEATED_INIT_TAG_NAME):Connect(AddSeatInitListener)    
end
