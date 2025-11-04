local dir = require(script.Parent.Parent.Parent.Directory)
local FXActivator = require(dir.Modules.FX.FXActivator)
local FXCreator = require(dir.Modules.FX.FXCreator)
local FXPreserve = require(dir.Modules.FX.FXPreserve)

--[[
Activate - plays particles from an EXISTING object. can play any particle
Create - plays a particle bundle at a location, not an existing object. can only play from assets
Preserve - intercepts and reparents particle holders right before destruction
]]
return {
    Activate = FXActivator,
    Create = FXCreator,
    Preserve = FXPreserve
}