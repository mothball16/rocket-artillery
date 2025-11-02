local Signal = require(game.ReplicatedStorage.Shared.mOS_Utility.Signal)
return {
    InitObject = Signal.new();
    DestroyObject = Signal.new();
}