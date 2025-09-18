local replicatedStorage = game:GetService("ReplicatedStorage")

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local charUtil = lib.FunctionUtils.Character

local sharedModules = replicatedStorage.Modules.Shared

local replicableInstance = require(sharedModules.Classes.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local inventorySharedUtil = require(sharedModules.Utils.InventoryUtilShared)

local directoryFolder = replicatedStorage.Directory

local itemsDirectory = require(directoryFolder.Items)

local module = setmetatable({}, { __index = replicableInstance }) --:: & replicableInstance.ClassType
module._Type = "Item"

export type ClassType =
	typeof(setmetatable(
		{} :: {
			PlayerOwner: Player?,
			CFrame: CFrame?,
			equipped: boolean,
			InstantiatedTo: string | Player,
		},
		{ __index = module }
	))
	& itemsDirectory.Type
	& replicableInstance.ClassType

function module.new(UID: string | number?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, replicableInstance, UID) :: ClassType
	self.equipped = false

	return self
end

function module.Materialize(self: ClassType, CF: CFrame)
	if not t.CFrame(CF) then
		return false
	end

	self.CFrame = lib.Utils.GetLegalCFrame(CF)
	return self
end

function module.canAddToInventory(self: ClassType, inv: { any })
	if not inventorySharedUtil.canAddItem(inv, self.UID) then
		return false
	end

	return true
end

function module.canAddToChest(self: ClassType, chestUID: string, contentName: string?)
	if not t.Player(self.InstantiatedTo) then
		return false
	end

	local chest = instancesManager.getObj(chestUID)
	if not chest or chest._Type ~= "Chest" then
		return false
	end

	if not chest:canAddItem(self.UID, contentName) then
		return false
	end

	return true
end

function module.canRemoveFromInventory(self: ClassType, inv: { any })
	if not inventorySharedUtil.checks.findItemInInventory(inv, self.UID) then
		return false
	end

	return true
end

function module.canRemoveFromChest(self: ClassType, chestUID: string)
	if type(self.InstantiatedTo) ~= "string" or self.InstantiatedTo == "" then
		return false -- Isn't in a chest
	end
	local chest = instancesManager.getObj(chestUID)
	if not chest or chest._Type ~= "Chest" then
		return false
	end
	if not chest:canRemoveItem(self.UID) then
		return false
	end
	return true
end

function module.canDrop(self: ClassType)
	if self.InstantiatedTo == "" then
		return false
	end

	return true
end

function module.InstantiateTo(self: ClassType, newInstantiate: string | Player, chestStorage)
	local last = self.InstantiatedTo
	if last == newInstantiate then
		return false
	end

	local newInstantiateIsPlayer = t.Player(newInstantiate)
	local newInstantiateIsGround = newInstantiate == ""
	local newInstantiateIsChest = type(newInstantiate) == "string" and newInstantiate ~= ""
	do
		if newInstantiateIsChest then
			local newObj = instancesManager.getObj(newInstantiate :: string)
			newInstantiateIsChest = newObj and newObj._Type == "Chest" and true or false
		end
	end

	local oldInstantiateIsPlayer = t.Player(last)
	local oldInstantiateIsGround = last == ""
	local oldInstantiateIsChest = type(last) == "string" and last ~= ""
	do
		if oldInstantiateIsChest then
			local lastobj = instancesManager.getObj(last :: string)
			oldInstantiateIsChest = lastobj and lastobj._Type == "Chest" and true or false
		end
	end

	self.InstantiatedTo = newInstantiate
	if newInstantiateIsGround then
		self:Drop()
	elseif newInstantiateIsChest then
		if oldInstantiateIsPlayer then
			local inv = inventorySharedUtil.getPlayerInventory(last :: Player)
			self:RemoveFromInventory(inv)
		end
		self:AddToChest(newInstantiate :: string, chestStorage)
	elseif newInstantiateIsPlayer then
		if oldInstantiateIsPlayer then
			self:RemoveFromInventory(inventorySharedUtil.getPlayerInventory(last :: Player))
		elseif oldInstantiateIsChest then
			self:RemoveFromChest(last)
			--elseif oldInstantiateIsGround then
			-- nothing to remove
		end

		self:AddToInventory()
	end

	return self
end

function module.TryToInstantiateTo(self: ClassType, newInstantiate: string | Player, chestStorage: string?)
	local last = self.InstantiatedTo
	if last == newInstantiate then
		return false
	end

	local newInstantiateIsPlayer = t.Player(newInstantiate)
	local newInstantiateIsGround = newInstantiate == ""
	local newInstantiateIsChest = type(newInstantiate) == "string" and newInstantiate ~= ""
	do
		if newInstantiateIsChest then
			local newObj = instancesManager.getObj(newInstantiate :: string)
			newInstantiateIsChest = newObj and newObj._Type == "Chest" and true or false
		end
	end

	local oldInstantiateIsPlayer = t.Player(last)
	local oldInstantiateIsGround = last == ""
	local oldInstantiateIsChest = type(last) == "string" and last ~= ""
	do
		if oldInstantiateIsChest then
			local lastobj = instancesManager.getObj(last :: string)
			oldInstantiateIsChest = lastobj and lastobj._Type == "Chest" and true or false
		end
	end

	if newInstantiateIsGround then
		if not self:canDrop() then
			return false
		end
	elseif newInstantiateIsChest then
		if not oldInstantiateIsPlayer then
			return false
		end

		if not self:canAddToChest(newInstantiate :: string, chestStorage) then
			return false
		end

		if not self:canRemoveFromInventory(inventorySharedUtil.getPlayerInventory(self.InstantiatedTo :: Player)) then
			return false
		end
	elseif newInstantiateIsPlayer then
		local inv = inventorySharedUtil.getPlayerInventory(newInstantiate :: Player)
		if not self:canAddToInventory(inv) then
			return false
		end
		if oldInstantiateIsChest then
			if not self:canRemoveFromChest(last) then
				return false
			end
		elseif oldInstantiateIsPlayer then
			if not self:canRemoveFromInventory(inventorySharedUtil.getPlayerInventory(last :: Player)) then
				return false
			end
		elseif oldInstantiateIsGround then
			-- nothing to remove
		else
			return false
		end
	end

	self:InstantiateTo(newInstantiate, chestStorage)
	return self
end

function module.Drop(self: ClassType)
	local cf = t.Player(self.InstantiatedTo) and charUtil.getAlivePlayerRootPart(self.InstantiatedTo).CFrame
		or self.InstantiatedTo.CFrame
	self.CFrame = cf * CFrame.new(0, -3, 0)
	self:InstantiateTo("")

	return self
end

function module.SetOwner(self: ClassType, plr: Player?)
	self.PlayerOwner = plr
	return self
end

function module.AddToInventory(self: ClassType, inv: { any }?, slot: number?)
	local plr = self.InstantiatedTo
	if not t.Player(plr) then
		return false
	end

	local inventory = inv or inventorySharedUtil.getPlayerInventory(plr)
	if not inventory then
		return false
	end
	if inventorySharedUtil.canAddItem(inventory, self.UID) then
		self:TryToInstantiateTo(self.InstantiatedTo)
		slot = slot or inventorySharedUtil.getNextSlotForANewItem(inventory)
		inventorySharedUtil.addItemToInventory(self.UID, inventory, slot)
		return self
	end

	return false -- Nǜo pode adicionar ao inventǭrio
end

function module.AddToChest(self: ClassType, chestUID: string, contentTabName: string?)
	if not chestUID or type(chestUID) ~= "string" then
		return false
	end

	local chest = instancesManager.getObj(chestUID)
	if not chest or chest._Type ~= "Chest" then
		return false
	end

	self:InstantiateTo(chestUID, contentTabName)
	chest:AddItem(self.UID, contentTabName)
	return self
end

function module.RemoveFromChest(self: ClassType, chestUID: string)
	local chest = instancesManager.getObj(chestUID)
	if not chest or chest._Type ~= "Chest" then
		return false
	end

	chest:RemoveItem(self.UID)
	return true
end

function module.RemoveFromInventory(self: ClassType, inv: { any })
	if not inv then
		return false
	end

	-- Remove o item do inventário
	inventorySharedUtil.removeItem(inv, self.UID)
	return true
end

return module
