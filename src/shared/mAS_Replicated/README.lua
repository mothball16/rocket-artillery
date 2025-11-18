--[=[
this codebase used to be <400 lines long...

mothball artillery system - how to set up everything
msg me on cord @ mothball16 for help

PHYSICAL TURRET SETUP
- Required Folder: Clone a required folder from some working example unless you want to hurt 
yourself. Then, set the object values as to what they're named. This should be fairly obvious.

- Welding: The setup I usually do is:
    1. 
    - Add a "Base" part as your anchor to the outside model or whatever you're 
      using to attach your turret to
    - Orient part to the center of your pivot and make sure it's forward and upright
      (A lot of common vehicle scripts on Roblox may auto-weld your vehicle. Make sure 
      that your turret is ignored by the auto-weld or everything will not work)

    2. 
    - Add a "BaseRot" part at the exact same position and orientation
    - Weld all parts you want rotating left/right to this part. 
    - Only the BaseRot should be welded to the Base

    3. 
    - Place "ElevationBase" part wherever you want the vertical pivot to be 
    - Orient part to the right-side of the turret, facing leftward and upright
    - Weld this Elevation part to the BaseRot

    4. 
    - Add an "ElevationRot" part at the exact same position and orientation
    - Weld all parts you want rotating up/down to this part
    - Only the ElevationRot should be welded to the ElevationBase

PHYSICAL PROJECTILE SETUP
tba

BASIC CONFIGURATION
- Turrets: tba

- Projectiles: tba


TROUBLESHOOTING

1. compass is off/reversed!
- Look for OrientationReader.lua and modify options as necessary. (Instructions in file)

2

ADVANCED CONFIGURATION
- Projectile behaviors: Lua doesn't have interfaces, so you'll just need to make sure you add
the existing methods for OnFire/OnHit behaviors. Look into the scripts to figure out how they 
look like. If you're doing something with this I'm assuming you code better than I do so you 
should probably be able to figure it out pretty easily.


- Template for a component
========================================================================================
local component = {}
component.__index = component

-- this isn't necessary, but ideally you want to put all assertions and extraction of info from required here
-- this way the constructor isnt filled with that and your code fails fast if not properly setup
local function _checkSetup(required)
    
end

-- args is the table you use as the config for your component, validate before using
function component.new(args, required)
    local self = {}

    assert()
    return self
end

-- ()
function component:DoSomething()
    do something here : o
end

return component
========================================================================================

[Communicating from client controller to a server controller]
1. on startup, get ID of the object on the client with NetUtils:GetId(required) -> this will return the attribute identifier used to find the object
...
2. fire event, with the ID as an arg with NetUtils:FireServer(evt, id, ...)     -> this will let the server identify which object you are referring to
3. on server handler, retrieve the object with NetUtils:GetObject(id)           -> this will make the server retrieve the object from the object registry. you now have the table of components
4. retrieve server controller from the object table + validate the request      -> this will make sure there even is a server controller to interact with, and will abort early if not found
5. the handler can now call server controller methods!

[Communicating from server controller to client controller]
follow above steps, but replace Server with Client
^ WARNING! given the constraints of this framework, this should only ever communicate back to the original client. if the server needs to communicate to multiple clients, use a manager
]=]