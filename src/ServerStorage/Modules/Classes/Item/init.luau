local ReplicatedStorage = game:GetService("ReplicatedStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")

local TypeHelp = require(ReplicatedStorage.Modules.Shared.Packages.Forbidden.Common.TypeHelp)
local t = require(ReplicatedStorage.lib.lib.ModuleUtils._Zone.SimpleZone.Utility.t)
local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t

local sharedModules = replicatedStorage.Modules.Shared
local sharedClasses = sharedModules.Classes
local itemSharedClass = require(sharedClasses.ItemClass)

local replicableInstanceClass = require(sharedClasses.BaseClasses.ReplicableInstanceClass)

local inventorySharedUtil = require(sharedModules.Utils.InventoryUtilShared)
local inventoryServerUtil = require(serverStorage.Modules.Utils.InventoryUtilServer)

-- local module = setmetatable({}, { __index = itemSharedClass })
-- module.__index = module

local module = {}
local moduleClass = itemSharedClass:newFromThis(module)

export type ClassType = itemSharedClass.ClassType & typeof(moduleClass) & {}

function module.new(id: string?): ClassType
	-- local self: ClassType = replicableInstanceClass.newLinkedToAClass(module, itemSharedClass.new()) :: ClassType
	local self = itemSharedClass.new():AddInheritance(moduleClass)

	if id then
		self:AttachId(id)
	end
	return self
end

function module.AttachId(self: ClassType, itemId: number)
	-- Chama o método shared do ReplicableInstanceClass primeiro
	itemSharedClass.AttachId(self, itemId)

	-- Lógica específica do servidor
	self.Remote:Fire(self.UID, "AttachId", { itemId })
	return self
end

function module.Materialize(self: ClassType, info: replicableInstanceClass.MaterializeInfo)
	local success = itemSharedClass.Materialize(self, info)
	if not success then
		return self
	end

	-- Lógica específica do servidor
	self.Remote:Fire(self.UID, "Materialize", {})
	return self
end

function module.InstantiateTo(self: ClassType, any: string | Player, ...)
	local success = itemSharedClass.InstantiateTo(self, any, ...)
	if not success then
		return self
	end

	if t.Player(any) then
		print(self.Model)
		if not self.Model then
			self:Materialize()
		end
		print(self.Model)
		print(self.Model.Parent)

		self.Model.Parent = (self.InstantiatedTo :: Player).Backpack
	elseif t.string(any) and any ~= "" then
		if self.Model then
			self.Model.Parent = nil
		end
	end

	-- Lógica específica do servidor
	self.Remote:Fire(self.UID, "InstantiateTo", { any, ... })
	return self
end

function module.Drop(self: ClassType)
	self.Remote:Fire(self.UID, "Drop", {})
	return self
end

function module.ToggleEquip(self: ClassType)
	local success = itemSharedClass.ToggleEquip(self)
	if not success then
		return self
	end

	return self
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
	if not t.Player(plr) or not any then
		chestStorage = any :: string
		any = plr
		plr = nil
	end
	local success = itemSharedClass.TryToInstantiateTo(self, any, chestStorage)
	if not success then
		return self
	end

	-- Apply the authoritative state change and replicate to clients
	self:InstantiateTo(any :: any, chestStorage)
	--dataStoreManager.updateClient(plr)
	return self
end

function module.EquipItem(self: ClassType)
	local success = itemSharedClass.EquipItem(self)
	if not success then
		return self
	end

	-- local inv = inventorySharedUtil.getPlayerInventory(self.InstantiatedTo)
	-- local slot = inventorySharedUtil.getItemSlot(inv, self.UID)
	-- print("slot", slot)
	-- inventorySharedUtil.toggleEquip(inv, slot)

	print(self.Model)
	if not self.Model then
		self:Materialize()
	end
	print(self.Model)
	print(self.Model.Parent)

	self.Model.Parent = self.InstantiatedTo.Character

	if self.Model:IsA("BasePart") then
		self.Model.Anchored = false
	end

	for _, part in self.Model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
		end
	end

	self.Remote:Fire(self.UID, "EquipItem", {})
	return self
end

function module.UnequipItem(self: ClassType)
	local success = itemSharedClass.UnequipItem(self)
	if not success then
		return self
	end

	self.Model.Parent = nil

	if self.Model:IsA("BasePart") then
		self.Model.Anchored = true
	end

	for _, part in self.Model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end

	self.Remote:Fire(self.UID, "UnequipItem", {})
	return self
end

function module.UseItem(self: ClassType, funcN: number)
	local success = itemSharedClass.UseItem(self, funcN)
	print("server use item", success)
	if not success then
		return self
	end

	self.Remote:Fire(self.UID, "UseItem", { funcN })
	return self
end

function module.TryToUseItem(self: ClassType, plr: Player, funcN: number)
	if t.Player(plr) and t.Player(self.InstantiatedTo) and plr == (self.InstantiatedTo :: Player) then
		if not itemSharedClass.CanUseItem(self, funcN) then
			return self
		end
		self:UseItem(funcN)
	end

	-- Apply the authoritative state change and replicate to clients
	--dataStoreManager.updateClient(plr)
	return self
end

function module.TryToEquip(self: ClassType, plr: Player)
	if t.Player(plr) and t.Player(self.InstantiatedTo) and plr == (self.InstantiatedTo :: Player) then
		self:EquipItem()
	end

	-- Apply the authoritative state change and replicate to clients
	--dataStoreManager.updateClient(plr)
	return self
end

function module.TryToUnequip(self: ClassType, plr: Player)
	if t.Player(plr) and t.Player(self.InstantiatedTo) and plr == (self.InstantiatedTo :: Player) then
		self:UnequipItem()
	end

	-- Apply the authoritative state change and replicate to clients
	--dataStoreManager.updateClient(plr)
	return self
end

function module.ReplicateTo(self: ClassType, client: Player?)
	local newItem = lib.Remotes.instanceCreated

	if client then
		newItem:FireClient(client, "Item", self.UID)

		self.Remote:FireClient(client, self.UID, "AttachId", { self.Id })
		self.Remote:FireClient(client, self.UID, "InstantiateTo", { self.InstantiatedTo })
		self.Remote:FireClient(client, self.UID, "Materialize", {})
	else
		newItem:Fire("Item", self.UID)

		self.Remote:Fire(self.UID, "AttachId", { self.Id })
		self.Remote:Fire(self.UID, "InstantiateTo", { self.InstantiatedTo })
		self.Remote:Fire(self.UID, "Materialize", {})
	end

	return self
end

return moduleClass
