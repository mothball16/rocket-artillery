--#region required
local dirClient = require(script.Parent.Parent.Parent.Directory)
local dir = dirClient.Main
local validator = dir.Validator.new(script.Name)
--#endregion required
--[[
instrument for UI tickmarks and stuff. coo
]]

local component = {}
component.__index = component

export type args = {
    parent: Instance,
    template: Instance,
    max: number,
    min: number,
    amount: number,
    placement: number,
    vertical: boolean,
    ascending: boolean,
    invert: boolean,
    loop: boolean,
}

local fallbacks: args = {
    max = 60,
    min = -20,
    amount = 9,
    placement = 0.5,
    vertical = true,
    ascending = true,
    invert = false, -- this isnt a "true" invert - i just have no idea why horizontal ticker isnt working and this is a temporary bandaid solution : P
    loop = false,
}

local function _checkSetup(required)
    
end
function component.new(args, _)
    local self = setmetatable({
        config = dir.Helpers:TableOverwrite(fallbacks, args)
    }, component)
    assert(self.config.max > self.config.min, "max cannot be less than min!")
    self.parent = args.parent
    self.config = self.config :: args

    local interval = (self.config.max - self.config.min) / self.config.amount
    local start, ending, increase
    if self.config.ascending then
        start = 0
        ending = self.config.amount
        increase = 1
        -- the last element of the seq. isn't rendered if looping because it would clip into the other one
        if self.config.loop then ending -= 1 end
    else
        start = self.config.amount
        ending = 0
        increase = -1
        -- (above explained)
        if self.config.loop then ending = 1 end
    end
    for i=start, ending, increase do
        local clone: Frame = args.template:Clone()
        local num: TextLabel = clone:FindFirstChild("Num")
        local tickTxt = tostring(interval * i + self.config.min)
        clone.Parent = args.template.Parent
        clone.Name = tickTxt
        clone.Size = self.config.vertical 
            and UDim2.fromScale(clone.Size.X.Scale, 1 / self.config.amount)
            or UDim2.fromScale(1 / self.config.amount, clone.Size.Y.Scale)
        num.Text = tickTxt .. "°"
        clone.Visible = true
    end


    if self.config.loop then
        local cloneR = args.template.Parent:Clone()
        cloneR.Parent = args.template.Parent.Parent
        cloneR.Position = UDim2.fromScale(1,0)

        local cloneL = args.template.Parent:Clone()
        cloneL.Parent = args.template.Parent.Parent
        cloneL.Position = UDim2.fromScale(-1,0)
    end
    return self
end

function component:Update(state)
    local scale = self.config.vertical and self.parent.Size.Y.Scale or self.parent.Size.X.Scale
    if self.config.invert then
        state = self.config.max - state
    end
    state = math.clamp(state, self.config.min, self.config.max)
    local adjustment = math.map(state, self.config.min, self.config.max, -scale, 0)

    if self.config.vertical then
        self.parent.Position = UDim2.fromScale(0, adjustment + 0.5)
    else
        self.parent.Position = UDim2.fromScale(adjustment + 0.5, 0)
    end
end

return component