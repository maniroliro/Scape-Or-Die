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

function module.new(): ClassType
	local self: ClassType = setmetatable(replicableInstance.new() :: lib.ReplicableInstance, module)

	return self
end

function module.AttachId(self: ClassType, _itemId: number)
	self.Remote:Fire(self.UID, "AttachId", { self.id })
	return self
end

function module.Materialize(self: ClassType, _CF: CFrame)
	self.Remote:Fire(self.UID, "Materialize", { self.CFrame })
	return self
end

function module.InstantiateTo(self: ClassType, any: string | Player, ...)
	self.Remote:Fire(self.UID, "InstantiateTo", { any, ... })
	return self
end

function module.Drop(self: ClassType)
	self.Remote:Fire(self.UID, "Drop", {})
	return self
end

function module.ToggleEquip(self: ClassType) end

function module.TryToInstantiateTo(self: ClassType, plr: Player, any: string | Player?, chestStorage: string?)
	print(plr, any, chestStorage)
	print(self.InstantiatedTo)
	any = any or plr
	if self.InstantiatedTo == any then
		return self
	end

	local isPlayer = (typeof(any) == "Instance" and any:IsA("Player"))
	local isChest = (type(any) == "string" and any ~= "")
	local isGround = (type(any) == "string" and any == "")

	if not (isPlayer or isChest or isGround) then
		return self
	end

	if type(self.InstantiatedTo) == "string" and self.InstantiatedTo ~= "" then
		local chestNow = instancesManager.getObj(self.InstantiatedTo)
		if chestNow then
			chestNow:RemoveItem(self.UID)
		end
	end

	if isGround then
		self:Drop()
	elseif isChest then
		local chest = instancesManager.getObj(any)
		if chest then
			chest:AddItem(self.UID, chestStorage)
		end
	elseif isPlayer then
		local plrDataInfo = dataStoreManager.getProfileData(plr)
		local inv = plrDataInfo.inventory
		print(inv)
		if inventorySharedUtil.canAddItem(inv, self.UID) then
			inventorySharedUtil.addItemToInventory(self.UID, inv)

			local chest = instancesManager.getObj(self.InstantiatedTo)
			if chest then
				print(chest.ItemsInside)
				chest:RemoveItem(self.UID)
				print(chest.ItemsInside)
			end
			print(inv)
			dataStoreManager.updateClient(plr)
		end
	end
	self:InstantiateTo(any, chestStorage)

	print(self.InstantiatedTo)
	return self
end

function module.ReplicateTo(self: ClassType, client: Player?)
	local newItem = lib.Remotes.instanceCreated.Item

	if client then
		local response = newItem:FireClient(client, self.UID)

		self.Remote:FireClient(client, self.UID, "AttachItem", { self.Id })
		self.Remote:FireClient(client, self.UID, "Materialize", { self.CFrame })
		self.Remote:FireClient(client, self.UID, "InstantiateTo", { self.InstantiatedTo })
	else
		newItem:Fire(self.UID)

		self.Remote:Fire(self.UID, "AttachItem", { self.Id })
		self.Remote:Fire(self.UID, "Materialize", { self.CFrame })
		self.Remote:Fire(self.UID, "InstantiateTo", { self.InstantiatedTo })
	end

	return self
end

return module
