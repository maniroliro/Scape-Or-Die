local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local replicableInstance = require(sharedModules.Classes.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local directoryFolder = replicatedStorage.Directory

local chestDirectory = require(directoryFolder.Chests)

local module = setmetatable({}, { __index = replicableInstance }) --:: & replicableInstance.ClassType

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

function module.new(id: string | number?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, replicableInstance) :: ClassType
	self._Type = "Chest"
	self.ItemsInside = {
		DeskContents = {},
		HiddenContents = {},
	}

	if id then
		self:AttachId(id)
	end
	return self
end

function module.getNextFreeSlot(self: ClassType, contentName: Storages)
	if not contentName then
		return
	end
	local items: ChestItems = self.ItemsInside
	local chestStorage = items[contentName]
	local maxNOfItems = Storages[contentName].MaxAmountOfItems
	if maxNOfItems <= #chestStorage then
		return self
	end

	print(#chestStorage)
	for i = 1, maxNOfItems do
		local uid = chestStorage[i]
		if not uid then
			return i
		end
	end

	return self
end

function module.AddItem(self: ClassType, itemUID: string, contentName: Storages)
	if not itemUID then
		return self
	end
	local item = instancesManager.getObj(itemUID)
	if not item then
		return self
	end
	contentName = contentName or "DeskContents"

	local items: ChestItems = self.ItemsInside
	local contentTab = items[contentName]
	if table.find(contentTab, itemUID) then
		return self
	end

	local pos = self:getNextFreeSlot(contentName)
	if pos then
		contentTab[pos] = itemUID
		item:InstantiateTo(self.UID, contentName)
	end

	return self
end

function module.RemoveItem(self: ClassType, itemUID: string, contentName: Storages?)
	print("REMOVE")
	print(itemUID)
	print(self.ItemsInside)

	if contentName then
		local items: ChestItems = self.ItemsInside
		local chestStorage = items[contentName]
		local pos = table.find(chestStorage, itemUID)
		if pos then
			chestStorage[pos] = nil
		end
	else
		print()
		local items: ChestItems = self.ItemsInside
		for _, storage in items do
			local pos = table.find(storage, itemUID)
			print(storage)
			print(pos)
			if pos then
				print(storage[pos])
				storage[pos] = nil
				return self
			end
		end
	end
	print(self.ItemsInside)

	return self
end

function module.UpdatePlayerSearching(_self: ClassType, _plr: Player)
	--SERVER ONLY
end

function module.playerBeganHoldingProximityPrompt(_self: ClassType, _plr: Player)
	--SERVER ONLY
end

function module.updatePlayerItensInside(self: ClassType, plr: Player, nothing: boolean?)
	if nothing then
		self.Remote:FireClient(plr, self.UID, "UpdateItemsInside", { { DeskContents = {}, HiddenContents = {} } })
	else
		print(self.PlayerOwner)
		local tabToSend = {}
		local items: ChestItems = self.ItemsInside
		for contentName, contentTab in items do
			local owner = self.PlayerOwner :: Player?
			if owner and owner ~= plr and contentName == "HiddenContents" then
				continue
			end
			tabToSend[contentName] = {}
			for _, itemUID in contentTab do
				table.insert(tabToSend[contentName], itemUID)
				local item = instancesManager.getObj(itemUID)
				if item then
					item:Replicate(true)
				end
			end
		end
		print(tabToSend)
		self.Remote:FireClient(plr, self.UID, "UpdateItemsInside", { tabToSend })
	end
	return self
end

function module.SetOwner(self: ClassType, plr: Player?)
	if not t.Player(plr) then
		return self
	end

	self.PlayerOwner = plr
	return self
end

return module
