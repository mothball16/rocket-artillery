--[[
    sets up tagged objects and sends a request to build the object when initialization conditions meet
]]

local dir = require(game.ReplicatedStorage.Shared.mOS_Replicated.Directory)
local HTTP = game:GetService("HttpService")
local CS = game:GetService("CollectionService")

local ServerSignals = dir.ServerSignals

local function _checkServerPreload(required)
    if not required:GetAttribute(dir.Consts.LAZY_LOAD_SERVER_CONTROLLER_ATTR) then
        ServerSignals.InitObject:Fire(required)
    end
end

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
    if player then
        dir.NetUtils:FireClient(player, dir.Events.Reliable.OnInitialize, required)
    end
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
    _checkServerPreload(required)
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

local function AddToolInitListener(required)
    local tool = required.Parent
    assert(tool:IsA("Tool"), "you cant add a tool init listener to a non-tool idiot")
    local owner = nil
    local toolId =  HTTP:GenerateGUID()
    required:SetAttribute(dir.Consts.OBJECT_IDENT_ATTR, toolId)
    --_checkServerPreload(required)
    tool.Equipped:Connect(function()
        local char = tool.Parent
        local player = game.Players:GetPlayerFromCharacter(char)
        if player then
            owner = player
            Initialize(player, required)
        end
    end)
    tool.Unequipped:Connect(function()
        if not owner then return end
        Destroy(owner, required)
    end)
end



return function()
    for _, v in pairs(CS:GetTagged(dir.Consts.SEATED_INIT_TAG_NAME)) do
        AddSeatInitListener(v)
    end
    for _, v in pairs(CS:GetTagged(dir.Consts.TOOL_INIT_TAG_NAME)) do
        AddToolInitListener(v)
    end

    for _, v in pairs(CS:GetTagged(dir.Consts.SPAWN_INIT_TAG_NAME)) do
        _checkServerPreload(v)
    end

    CS:GetInstanceAddedSignal(dir.Consts.SEATED_INIT_TAG_NAME):Connect(AddSeatInitListener)
    CS:GetInstanceAddedSignal(dir.Consts.TOOL_INIT_TAG_NAME):Connect(AddToolInitListener)
    CS:GetInstanceAddedSignal(dir.Consts.SPAWN_INIT_TAG_NAME):Connect(_checkServerPreload)
end
