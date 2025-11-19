--[[
handles attachment retrieval and validation, holds no authority on rack state
The selector now handles sequential indices based on numeric part names (1, 2, 3...)
- slotsByIndex - used for all lookups (AttachAt / DetachAt / Iterate)
- currentIndex - used to keep track of the next slot to iterate through
]]


local dir = require(script.Parent.Parent.Parent.Directory)
local ProjectileRegistry = require(dir.Modules.Projectile.ProjectileRegistry)
local validator = dir.Validator.new(script.Name)
local AttachSelector = {}
AttachSelector.__index = AttachSelector

--local SLOT_TYPE_ATTR = "SlotType"
local fallbacks = {}

local function _checkSetup(required)
	local attachPoints = validator:ValueIsOfClass(required:FindFirstChild("AttachPoints"), "Folder")
	local slotsByIndex = {}
	
	for i = 1, #attachPoints:GetChildren() do
		local slot = validator:IsOfClass(attachPoints:FindFirstChild(i), "BasePart")
		table.insert(slotsByIndex, slot)



		--local slotType = validator:HasAttr(slot,SLOT_TYPE_ATTR)
		--if not slotsByType[slotType] then slotsByType[slotType] = {} end
		--table.insert(slotsByType[slotType], slot)
	end

	return attachPoints, slotsByIndex
end

-- (args, required)
function AttachSelector.new(args, required)
	local attachPoints, slotsByIndex, slotsByType = _checkSetup(required)
	local self = setmetatable({}, AttachSelector)
	self.config = dir.Helpers:TableOverwrite(fallbacks, args)
	self.attachPoints = attachPoints
	self.slotsByIndex = slotsByIndex
	self.currentIndex = 1
	return self
end

function AttachSelector:SlotOccupied(attach)
	return attach:GetAttribute(dir.Consts.SLOT_OCCUPIED_ATTR) == true
end

function AttachSelector:SlotAt(index)
	return self.slotsByIndex[index]
end

function AttachSelector:GetAttachWeldAt(index)
	local slot = self:SlotAt(index)
	if not slot then
		return
	end
	return slot:FindFirstChild(dir.Consts.ATTACH_WELD_NAME)
end

-- returns: the projectile (model) itself, the configuration of the projectile, and the weld attaching the projectile to the slot
function AttachSelector:GetAttachPointDataAt(index): (Instance, {any}, Weld)
	local weld = self:GetAttachWeldAt(index)
	if not weld or not weld.Part1 or not weld.Part1.Parent then
		validator:Warn("no weld or no part1")
		warn(weld, weld.Part1, weld.Part1.Parent)
		return
	end
	local projectileInstance = weld.Part1.Parent
	local config = ProjectileRegistry:GetProjectile(projectileInstance.Name)

	if not projectileInstance then
		validator:Warn("weld part1 of rocket link is not connected? at slot " .. tostring(index))
	end
	return projectileInstance, config, weld
end

-- retrieves the first occupied slot of slot type
function AttachSelector:Iterate(wantsOccupiedSlot, wantsSpecificType)
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
		if wantsOccupiedSlot == false and not slotIsOccupied then
			return slot
		elseif slotIsOccupied then
			if not wantsSpecificType then
				return slot
			end

			local _, config, _ = self:GetAttachPointDataAt(currentIndex)
			if config.Config.ID == wantsSpecificType then
				return slot
			end
		end
	end

	return nil
end

function AttachSelector:FindNextEmpty()
	local index, slot = self:Iterate(false)
	return index, slot
end

function AttachSelector:FindNextFull(wantsSpecificType)
	local index, slot = self:Iterate(true, wantsSpecificType)
	return index, slot
end

function AttachSelector:GetSlots()
	return self.attachPoints
end

function AttachSelector:GetSlotsByID(): {[string]: {name: string, slots: {Instance}}}
	local slotData = {}
	for i = 1, #self.slotsByIndex do
		local slot = self.slotsByIndex[i]
		if not self:SlotOccupied(slot) or not slot:FindFirstChild(dir.Consts.ATTACH_WELD_NAME) then continue end
		local _, config, _ = self:GetAttachPointDataAt(i)
		local ID = config.Config.ID
		local name = (config.Config.name or "none")
		if not ID then
			validator:Warn("Attachments should ALWAYS have IDs.")
			continue
		end
		if not slotData[ID] then slotData[ID] = {name = name, slots = {}} end
		table.insert(slotData[ID].slots, slot)
	end
	return slotData
end

function AttachSelector:Destroy()
	
end

return AttachSelector