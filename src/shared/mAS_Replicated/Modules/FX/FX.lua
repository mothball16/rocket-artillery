local dir = require(script.Parent.Parent.Parent.Directory)
local FXActivator = require(dir.Modules.FX.FXActivator)
local FXCreator = require(dir.Modules.FX.FXCreator)
local FXPreserve = require(dir.Modules.FX.FXPreserve)

return {
    Activate = FXActivator,
    Create = FXCreator,
    Preserve = FXPreserve
}