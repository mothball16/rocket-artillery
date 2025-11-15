--#region required
local dir = require(script.Parent.Parent.Parent.Directory)
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
this script enforces style guidelines for every tagged folder. guidelines:
- All folders must have respective _Client and _Server folders
- All modules must be in a folder named "Modules"
- All modules within the Modules folder must be grouped in a subfolder representing their system
- All folders must have a ModuleScript named "Bootstrapper"
- All folders must have a ModuleScript named "Directory" that has the following:
    - Root: script.Parent
    - Modules: script.Parent.Modules
    - (Server/Client): Repl (the replicated folder for that system)
]]

return function()
    --TBA
end