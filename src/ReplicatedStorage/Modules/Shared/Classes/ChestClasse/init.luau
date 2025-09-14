local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local replicableInstance = require(sharedModules.Classes.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local directoryFolder = replicatedStorage.Directory

local chestDirectory = require(directoryFolder.Chests)

local module = setmetatable({}, { __index = replicableInstance }) --:: & replicableInstance.ClassType
module._Type = "Chest"

local Storages = {
	DeskContents = {
		Name = "DeskContents",
		MaxAmountOfItems = 12,
	},
	HiddenContents = {
		Name = "HiddenContents",
		MaxAmountOfItems = 6,
	},
}

export type Storages = "DeskContents" | "HiddenContents"

export type ChestItems = {
	DeskContents: { string },
	HiddenContents: { string },
}

export type ClassType = typeof(setmetatable(
	{} :: {
		PlayerOwner: Player?,
		CFrame: CFrame,
		ItemsInside: ChestItems,
	},
	{ __index = module }
)) & replicableInstance.ClassType & chestDirectory.Type

function module.new(UID: string | number?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, replicableInstance, UID) :: ClassType
	self.ItemsInside = {
		DeskContents = {},
		HiddenContents = {},
	}

	return self
end

function module.isPosAFreeSlot(self: ClassType, contentName: Storages, pos: number)
	if not contentName or type(pos) ~= "number" then
		return false
	end
	local items: ChestItems = self.ItemsInside
	local chestStorage = items[contentName]
	if chestStorage[pos] then
		return false
	end
	return pos
end

function module.getNextFreeSlot(self: ClassType, contentName: Storages)
	if not contentName then
		return self
	end
	local items: ChestItems = self.ItemsInside
	local chestStorage = items[contentName]
	local maxNOfItems = Storages[contentName].MaxAmountOfItems
	-- count non-nil entries to handle sparse arrays
	local count = 0
	for _, uid in chestStorage do
		if uid then
			count += 1
		end
	end
	if count >= maxNOfItems then
		return nil
	end
	for i = 1, maxNOfItems do
		local uid = chestStorage[i]
		print(i, uid)
		if not uid then
			return i
		end
	end

	return nil
end

function module.canRemoveItem(self: ClassType, itemUID: string)
	print(itemUID)
	if not itemUID or type(itemUID) ~= "string" then
		return false
	end

	local items: ChestItems = self.ItemsInside
	print(items)
	for _, storage in items do
		print(storage)
		for _, uid in storage do
			if uid == itemUID then
				return true
			end
		end
	end
	print()
	return false
end

function module.canAddItem(self: ClassType, itemUID: string, contentName: Storages)
	if not itemUID or type(itemUID) ~= "string" then
		return false
	end

	local item = instancesManager.getObj(itemUID)
	if not item then
		return false
	end

	contentName = contentName or "DeskContents"

	local items: ChestItems = self.ItemsInside
	local contentTab = items[contentName]
	for _, uid in contentTab do
		if uid == itemUID then
			return false -- Item já está no chest
		end
	end
	local pos = self:getNextFreeSlot(contentName)
	if type(pos) ~= "number" then
		return false
	end

	return pos
end

function module.AddItem(self: ClassType, itemUID: string, contentName: Storages, pos: number?)
	if not itemUID or type(itemUID) ~= "string" then
		return false
	end

	local item = instancesManager.getObj(itemUID)
	if not item then
		return false
	end

	local maybepos = self:canAddItem(itemUID, contentName)
	if not maybepos then
		return false
	end
	print(pos)
	pos = pos and self:isPosAFreeSlot(contentName, pos) or maybepos
	print(pos)
	if not pos then
		return false -- Não pode adicionar
	end

	contentName = contentName or "DeskContents"
	local items: ChestItems = self.ItemsInside
	local contentTab = items[contentName]

	contentTab[pos] = itemUID
	item:InstantiateTo(self.UID, contentName)
	print()
	return pos
end

function module.UpdatePlayerSearching(self: ClassType, plr: Player)
	--SERVER ONLY

	return self
end

function module.playerBeganHoldingProximityPrompt(self: ClassType, plr: Player)
	--SERVER ONLY

	return self
end

function module.SetOwner(self: ClassType, plr: Player?)
	if not t.Player(plr) then
		return self
	end

	self.PlayerOwner = plr
	return self
end

-- Safer RemoveItem that handles sparse arrays (override)
function module.RemoveItem(self: ClassType, itemUID: string, contentName: Storages?)
	if not itemUID or type(itemUID) ~= "string" then
		return false
	end

	local items: ChestItems = self.ItemsInside
	if contentName then
		local storage = items[contentName]
		if not storage then
			return false
		end
		for i, uid in storage do
			if uid == itemUID then
				storage[i] = nil
				return true
			end
		end
		return false
	end

	for _, storage in items do
		for i, uid in storage do
			if uid == itemUID then
				storage[i] = nil
				return true
			end
		end
	end

	return false
end

return module
