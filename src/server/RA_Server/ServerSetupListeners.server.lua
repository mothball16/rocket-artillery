-- Listens for setup triggers on the server-side.

local dir = require(game.ReplicatedStorage.Shared.RA_Directory)
local OnSeatedSetup = require(dir.Modules.Core.OnSeatedSetup)

local CS = game:GetService("CollectionService")
local SEATED_INIT_TAG_NAME = "mothballArtySystem_RunOnSeated"

local function AddSeatListeners(required)
    OnSeatedSetup.ConnectControlSeat(required)
end

for _, v in pairs(CS:GetTagged(SEATED_INIT_TAG_NAME)) do
    AddSeatListeners(v)
end

CS:GetInstanceAddedSignal(SEATED_INIT_TAG_NAME):Connect(AddSeatListeners)
