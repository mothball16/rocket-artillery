--[[
handles attachment retrieval and validation, holds no authority on rack state
The selector now handles sequential indices based on numeric part names (1, 2, 3...)
- slotsByIndex - used for all lookups (AttachAt / DetachAt / Iterate)
- currentIndex - used to keep track of the next slot to iterate through
]]


local dir = require(game.ReplicatedStorage.Shared.mAS_Directory)
local ProjectileRegistry = require(dir.Modules.Core.ProjectileRegistry)
local validator = dir.Validator.new(script.Name)
local AttachSelector = {}
AttachSelector.__index = AttachSelector

local fallbacks = {}

local function _checkSetup(required)
	local attachPoints = validator:ValueIsOfClass(required:FindFirstChild("AttachPoints"), "Folder")
	local slotsByIndex = {}

	for i = 1, #attachPoints:GetChildren() do
		
		table.insert(slotsByIndex, validator:IsOfClass(attachPoints:FindFirstChild(i), "BasePart"))
	end

	return attachPoints, slotsByIndex
end

-- (args, required)
function AttachSelector.new(args, required)
	local attachPoints, slotsByIndex = _checkSetup(required)
	local self = setmetatable({}, AttachSelector)
	self.config = dir.FallbackConfig.new(args, fallbacks)
	self.attachPoints = attachPoints
	self.slotsByIndex = slotsByIndex
	self.currentIndex = 1
	return self
end

-- (attach)
function AttachSelector:SlotOccupied(attach)
	return attach:GetAttribute("Occupied") == true
end

-- (index)
function AttachSelector:SlotAt(index)
	return self.slotsByIndex[index]
end

-- (index)
function AttachSelector:GetAttachWeldAt(index)
	local slot = self:SlotAt(index)
	if not slot then
		return
	end
	return slot:FindFirstChild(dir.Consts.ATTACH_WELD_NAME)
end

function AttachSelector:GetAttachPointDataAt(index)
	local weld = self:GetAttachWeldAt(index)
	if not weld or not weld.Part1 or not weld.Part1.Parent then
		validator:Warn("no weld or no part1")
		return
	end
	local projectileInstance = weld.Part1.Parent
	local config = ProjectileRegistry:GetProjectile(projectileInstance.Name)
	if not config then
		validator:Warn("no projectile found for name " .. projectileInstance.Name)
		return
	end
	if not projectileInstance then
		validator:Warn("weld part1 of rocket link is not connected? at slot " .. tostring(index))
	end
	return projectileInstance, config, weld
end

-- (wantsOccupiedSlot)
function AttachSelector:Iterate(wantsOccupiedSlot)
	local slots = self.slotsByIndex
	if #slots == 0 then return nil end

	local numSlots = #slots
	local startIndex = self.currentIndex

	for i = 1, numSlots do
        --[[ oh my one based indexing..
		assuming: startIndex = 3, numSlots = 5
		(3 + 1 - 2) % 5 + 1 = 2 % 5 + 1 = 3, (3 + 2 - 2) % 5 + 1 = 3 % 5 + 1 = 4
		(3 + 3 - 2) % 5 + 1 = 4 % 5 + 1 = 5, (3 + 4 - 2) % 5 + 1 = 5 % 5 + 1 = 1
		(3 + 5 - 2) % 5 + 1 = 5 % 5 + 1 = 2
		]]
		local currentIndex = (startIndex + i - 2) % numSlots + 1
		local slot = slots[currentIndex]
		local slotIsOccupied = self:SlotOccupied(slot)

		-- don't jump the slot here, there's a chance this slot would be reloaded before next shot
		if (wantsOccupiedSlot == slotIsOccupied) then
			return slot
		end
	end

	return nil
end

-- ()
function AttachSelector:FindNextEmpty()
	local index, slot = self:Iterate(false)
	return index, slot
end

-- ()
function AttachSelector:FindNextFull()
	local index, slot = self:Iterate(true)
	return index, slot
end

function AttachSelector:GetSlots()
	return self.attachPoints
end

function AttachSelector:Destroy()
	
end

return AttachSelector