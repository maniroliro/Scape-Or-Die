local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local replicableInstanceClass = require(sharedModules.Classes.BaseClasses.ReplicableInstanceClass)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local directoryFolder = replicatedStorage.Directory

local chestDirectory = require(directoryFolder.Chests)

-- local module = setmetatable({}, { __index = replicableInstanceClass }) --:: & replicableInstanceClass.ClassType
-- module._Type = replicableInstanceClass.ExtendType("Chest")

local module = {}
local moduleClass = replicableInstanceClass:newFromThis(module)
moduleClass:ExtendType("Chest")

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

export type ClassType = & replicableInstanceClass.ClassType & chestDirectory.Type & typeof(moduleClass) & {
	PlayerOwner: Player?,
	CFrame: CFrame,
	Model: Model, -- typeof(replicatedStorage.Assets.Directory.Chests["00 _ Template"].Model),
	ItemsInside: ChestItems,
	ChestOpen: string | boolean,
}

function module.new(UID: string?): ClassType
	--local self = replicableInstanceClass.newLinkedToAClass(module, replicableInstanceClass.new(UID)) :: ClassType
	local self = replicableInstanceClass.new(UID):AddInheritance(moduleClass)
	self.ItemsInside = {
		DeskContents = {},
		HiddenContents = {},
	}
	self.ChestOpen = false

	return self
end

function module.OpenChest(self: ClassType, gameCharacter: instancesManager.InstanceArgsType)
	local instance = instancesManager.getObj(gameCharacter)
	if not instance then
		return false
	end
	if not instance:IsA("GameCharacter") then
		return false
	end
	self.ChestOpen = instance.UID
	instance:TryToOpenChest(self)
	return self
end

function module.TryToOpenChest(self: ClassType, gameCharacter: instancesManager.InstanceArgsType)
	if self.ChestOpen then
		return false
	end
	print(gameCharacter)

	local instance = instancesManager.getObj(gameCharacter)
	print()
	if not instance then
		return false
	end
	print()
	if not instance:IsA("GameCharacter") then
		return false
	end
	print()
	if instance.ChestOpen then
		return false
	end
	print()
	self:OpenChest(gameCharacter)
	return self
end

function module.CloseChest(self: ClassType, gameCharacter: instancesManager.InstanceArgsType)
	print()
	if not self.ChestOpen then
		return false
	end
	print()

	local instance = instancesManager.getObj(gameCharacter)
	print()
	if not instance then
		return false
	end
	print()
	if not instance:IsA("GameCharacter") then
		return false
	end
	self.ChestOpen = false

	instance:CloseChest()
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
		if not uid then
			return i
		end
	end

	return nil
end

function module.canRemoveItem(self: ClassType, itemUID: string)
	if not itemUID or type(itemUID) ~= "string" then
		return false
	end

	local items: ChestItems = self.ItemsInside
	for _, storage in items do
		for _, uid in storage do
			if uid == itemUID then
				return true
			end
		end
	end
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
	pos = pos and self:isPosAFreeSlot(contentName, pos) or maybepos
	if not pos then
		return false -- Não pode adicionar
	end

	contentName = contentName or "DeskContents"
	local items: ChestItems = self.ItemsInside
	local contentTab = items[contentName]

	contentTab[pos] = itemUID
	item:InstantiateTo(self.UID, contentName)
	return pos
end

function module.SetOwner(self: ClassType, plr: Player?)
	if not t.Player(plr) then
		return false
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

return moduleClass
