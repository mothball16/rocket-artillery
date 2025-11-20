--[[
a wrapper around UIS for triggering actions
]]
local dirClient = require(script.Parent.Parent.Parent.Directory)
local dir = dirClient.Main
local UIS = game:GetService("UserInputService")

local InputSystem = {}
InputSystem.__index = InputSystem

export type InputSystem = {
    onAction: {[Enum.KeyCode]: ()->()};
    onInput: {[Enum.UserInputType]: ()->()};
    endAction: {[Enum.KeyCode]: ()->()};
    endInput: {[Enum.UserInputType]: ()->()};
}

function InputSystem.new(args, _)
    local self = setmetatable({}, InputSystem)
    self.maid = dir.Maid.new()

    self.onAction = {default = function() end}
    self.onInput = {default = function() end}
    self.endAction = {default = function() end}
    self.endInput = {default = function() end}

    for bind: EnumItem, func in pairs(args.on or {}) do
        if bind.EnumType == Enum.UserInputType then
            self.onInput[bind] = func
        elseif bind.EnumType == Enum.KeyCode then
            self.onAction[bind] = func
        end
    end

    for bind, func in pairs(args.off or {}) do
        if bind.EnumType == Enum.UserInputType then
            self.endInput[bind] = func
        elseif bind.EnumType == Enum.KeyCode then
            self.endAction[bind] = func
        end
    end

    self.maid:GiveTask(UIS.InputBegan:Connect(function(input, chatting)
		if chatting then
			return
		end
		if input.KeyCode then
	        dir.Helpers:Switch(input.KeyCode)(self.onAction)
		end
		if input.UserInputType then
	        dir.Helpers:Switch(input.UserInputType)(self.onInput)
		end
	end))

	self.maid:GiveTask(UIS.InputEnded:Connect(function(input, chatting)
		if chatting then
			return
		end
		if input.KeyCode then
			dir.Helpers:Switch(input.KeyCode)(self.endAction)
		end
		if input.UserInputType then
			dir.Helpers:Switch(input.UserInputType)(self.endInput)
		end
	end))

    return self
end

function InputSystem:Destroy()
	self.maid:DoCleaning()
end


return InputSystem