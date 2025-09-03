local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local packet = lib.ModuleUtils.Packet
local trove = lib.ModuleUtils.Trove
local replicableInstance = require(sharedModules.Classes.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)
local charUtils = lib.FunctionUtils.Character

local directoryFolder = replicatedStorage.Directory

local chestDirectory = require(directoryFolder.Chests)

local module = setmetatable({}, {__index = replicableInstance}) --:: & replicableInstance.ClassType

local Storages = {
	DeskContents = {
		Name = 'DeskContents',
		MaxAmountOfItems = 12,
	},
	HiddenContents = {
		Name = 'HiddenContents',
		MaxAmountOfItems = 6,
	},
}

export type Storages = 'DeskContents' | 'HiddenContents'

export type ClassType = typeof(setmetatable(
	{} :: {
		--isRunning: boolean,
		CFrame: CFrame,
		PlayerOwner: Player?,

		ItemsInside: {
			DeskContents: {string},
			HiddenContents: {string},
		}
	},
	{__index = module}
)) & replicableInstance.ClassType & chestDirectory.Type

function module.new(id: string | number?) : ClassType
	local self = replicableInstance.newLinkedToAClass(module, replicableInstance) :: ClassType
	self._Type = 'Chest'
	self.ItemsInside = {
		DeskContents = {},
		HiddenContents = {}
	}
	
	if id then self:AttachId(id) end
	return self
end

function module.Materialize(self: ClassType, CF: CFrame)
	if not t.CFrame(CF) then return self end
	CF = lib.Utils.GetLegalCFrame(CF)
	self.CFrame = CF
	
	return self
end

function module.getNextFreeSlot(self: ClassType, contentName: Storages)
	if not contentName then return end
	local chestStorage = self.ItemsInside[contentName]
	local maxNOfItems = Storages[contentName].MaxAmountOfItems
	if maxNOfItems <= #chestStorage then return self end

	print(#chestStorage)
	for i = 1, maxNOfItems do
		local uid = chestStorage[i]
		if not uid then 
			return i 
		end
	end
end

function module.AddItem(self: ClassType, itemUID: string , contentName: Storages)
	if not itemUID then return self end
	local item = instancesManager.getObj(itemUID)
	if not item then return self end
	contentName = contentName or 'DeskContents'
	
	local contentTab = self.ItemsInside[contentName]
	if table.find(contentTab, itemUID) then return self end
	
	local pos = self:getNextFreeSlot(contentName)
	if pos then
		contentTab[pos] = itemUID
		item:InstantiateTo(self.UID, contentName)
	end

	return self
end

function module.RemoveItem(self: ClassType, itemUID: string, contentName: Storages?)
	print('REMOVE')
	print(itemUID)
	print(self.ItemsInside)
	
	if contentName then
		local chestStorage = self.ItemsInside[contentName]
		local pos = table.find(chestStorage, itemUID)
		if pos then
			chestStorage[pos] = nil
		end
	else
		print()
		for _, storage in self.ItemsInside do
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

function module.UpdatePlayerSearching(self: ClassType, plr: Player)
	--SERVER ONLY
end

function module.playerBeganHoldingProximityPrompt(self: ClassType, plr: Player)
	--SERVER ONLY
end

function module.updatePlayerItensInside(self:ClassType, plr: Player, nothing: boolean?)
	if nothing then
		self.Remote:FireClient(plr, self.UID, 'UpdateItemsInside', {{DeskContents = {}, HiddenContents = {}}})
	else
		print(self.PlayerOwner)
		local tabToSend = {}
		for contentName, contentTab in self.ItemsInside do
			if self.PlayerOwner ~= plr and contentName == 'HiddenContents' then continue end
			tabToSend[contentName] = {}
			for i, itemUID in contentTab do
				table.insert(tabToSend[contentName], itemUID)
				local item = instancesManager.getObj(itemUID)
				if item then
					item:Replicate(true)
				end
			end
		end
		print(tabToSend)
		self.Remote:FireClient(plr, self.UID, 'UpdateItemsInside', {tabToSend})
	end
	return self
end

function module.SetOwner(self: ClassType, plr: Player?)
	if not t.Player(plr) then return self end

	self.PlayerOwner = plr
	return self
end

return module
