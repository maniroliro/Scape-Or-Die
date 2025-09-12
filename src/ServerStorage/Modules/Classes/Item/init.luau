local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")
local itemsDirectory = require(replicatedStorage.Directory.Items)

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t

local sharedModules = replicatedStorage.Modules.Shared
local sharedClasses = sharedModules.Classes
local itemSharedClass = require(sharedClasses.ItemClasse)

local replicableInstance = require(sharedClasses.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local inventoryServerUtil = require(serverStorage.Modules.Utils.InventoryUtilServer)
local inventorySharedUtil = require(sharedModules.Utils.InventoryUtilShared)

local dataStoreManager = require(serverStorage.Modules.Managers.PlayerDataManager)

local module = setmetatable({}, { __index = itemSharedClass })
module.__index = module

export type ClassType = typeof(setmetatable({} :: {}, module)) & itemSharedClass.ClassType

function module.new(id: string?): ClassType
	local self: ClassType = replicableInstance.newLinkedToAClass(module, itemSharedClass) :: ClassType
	self._Type = "Item"

	if id then
		self:AttachId(id)
	end
	return self
end

function module.AttachId(self: ClassType, itemId: number)
	-- Chama o método shared do ReplicableInstance primeiro
	replicableInstance.AttachId(self, itemId)

	-- Lógica específica do servidor
	self.Remote:Fire(self.UID, "AttachId", { itemId })
	return self
end

function module.Materialize(self: ClassType, _CF: CFrame)
	local success = itemSharedClass.Materialize(self, _CF)
	if not success then
		return self
	end

	-- Lógica específica do servidor
	self.Remote:Fire(self.UID, "Materialize", { self.CFrame })
	return self
end

function module.InstantiateTo(self: ClassType, any: string | Player, ...)
	print(any, ...)
	print("INSTANTIATING TO....", any, ...)
	local success = itemSharedClass.InstantiateTo(self, any, ...)
	print(success)
	if not success then
		return self
	end
	print("FIRING INSTANTIATED TO....", any, ...)
	-- Lógica específica do servidor
	self.Remote:Fire(self.UID, "InstantiateTo", { any, ... })
	return self
end

function module.Drop(self: ClassType)
	self.Remote:Fire(self.UID, "Drop", {})
	return self
end

function module.ToggleEquip(self: ClassType)
	--TODO:
end

function module.RemoveFromInventory(self: ClassType, inv: { any })
	local success = itemSharedClass.RemoveFromInventory(self, inv)
	if not success then
		return self
	end

	-- Lógica específica do servidor
	--dataStoreManager.updateClient(plr)
	return self
end

function module.TryToInstantiateTo(self: ClassType, plr: Player?, any: string | Player?, chestStorage: string?)
	print(self.Id, plr, any, chestStorage)
	if not t.Player(plr) or not any then
		chestStorage = any :: string
		any = plr
		plr = nil
	end
	print(self.Id, plr, any, chestStorage)
	local success = itemSharedClass.TryToInstantiateTo(self, any, chestStorage)
	if not success then
		return self
	end

	--dataStoreManager.updateClient(plr)
	return self
end

function module.ReplicateTo(self: ClassType, client: Player?)
	local newItem = lib.Remotes.instanceCreated.Item

	if client then
		newItem:FireClient(client, self.UID)

		self.Remote:FireClient(client, self.UID, "AttachId", { self.Id })
		self.Remote:FireClient(client, self.UID, "Materialize", { self.CFrame })
		self.Remote:FireClient(client, self.UID, "InstantiateTo", { self.InstantiatedTo })
	else
		newItem:Fire(self.UID)

		self.Remote:Fire(self.UID, "AttachId", { self.Id })
		self.Remote:Fire(self.UID, "Materialize", { self.CFrame })
		self.Remote:Fire(self.UID, "InstantiateTo", { self.InstantiatedTo })
	end

	return self
end

return module
