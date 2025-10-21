local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal
local charUtil = lib.FunctionUtils.Character

local sharedModules = replicatedStorage.Modules.Shared

local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local inventorySharedUtil = require(sharedModules.Utils.InventoryUtilShared)

local directoryFolder = replicatedStorage.Directory

local itemsDirectory = require(directoryFolder.Items)
local itemsFunctionDirectory = require(replicatedStorage.Directory.ItemsFunction)

local module = setmetatable({}, { __index = replicableInstance }) --:: & replicableInstance.ClassType
module._Type = replicableInstance.extendType("Item")

export type ClassType =
	typeof(setmetatable(
		{} :: {
			Model: Model, -- typeof(itemsDirectory.directoryFolder["00 _ Template"].Mo),
			PlayerOwner: Player?,
			CFrame: CFrame?,
			equipped: boolean,
			InstantiatedTo: string | Player,
			InstantiatedToChanged: lib.Signal<nil, string | Player>,
			--SlotOnInstantiatedTo: number?,

			ItemFunction1: itemsFunctionDirectory.Type,
			ItemFunction2: itemsFunctionDirectory.Type,
		},
		{ __index = module }
	))
	& itemsDirectory.Type
	& replicableInstance.ClassType

function module.new(UID: string?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, replicableInstance.new(UID)) :: ClassType
	self.equipped = false
	self.InstantiatedToChanged = self.Trove:Construct(signal)

	return self
end

function module.AttachId(self: ClassType, id: number)
	local sucess = replicableInstance.AttachId(self, id)
	if not sucess then
		return false
	end

	return self
end

function module.Materialize(self: ClassType, info: replicableInstance.MaterializeInfo)
	info = (info or {} :: any)
	if runService:IsClient() then
		info.Suffix = "Client"
	else
		info.Suffix = "Server"
	end

	local success = replicableInstance.Materialize(self, info)
	if not success then
		return false
	end

	local itemsFunctionTable = self.ItemFunction
	if not itemsFunctionTable or #itemsFunctionTable == 0 then
		return
	end
	local func1 = itemsFunctionDirectory:getItemInfo(itemsFunctionTable[1])
	local func2 = itemsFunctionDirectory:getItemInfo(itemsFunctionTable[2])
	print(func1, func2)
	self.ItemFunction1 = func1
	self.ItemFunction2 = func2
	return self
end

function module.canAddToChest(self: ClassType, chestUID: string, contentName: string?)
	if not t.Player(self.InstantiatedTo) then
		return false
	end

	local chest = instancesManager.getObj(chestUID)
	if not chest:IsA("Chest") then
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
	if not chest:IsA("Chest") then
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
			newInstantiateIsChest = newObj:IsA("Chest")
		end
	end

	local oldInstantiateIsPlayer = t.Player(last)
	local oldInstantiateIsGround = last == ""
	local oldInstantiateIsChest = type(last) == "string" and last ~= ""
	do
		if oldInstantiateIsChest then
			local lastobj = instancesManager.getObj(last :: string)
			oldInstantiateIsChest = lastobj:IsA("Chest")
		end
	end

	self.InstantiatedTo = newInstantiate
	self.InstantiatedToChanged:Fire(newInstantiate)

	if oldInstantiateIsPlayer then
		if self.equipped then
			self:UnequipItem()
		end
		local inv = inventorySharedUtil.getPlayerInventory(last :: Player)
		self:RemoveFromInventory(inv)
	elseif oldInstantiateIsChest then
		self:RemoveFromChest(last)
	end

	if newInstantiateIsGround then
		self:Drop()
	elseif newInstantiateIsChest then
		self:AddToChest(newInstantiate :: string, chestStorage)
	elseif newInstantiateIsPlayer then
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
			newInstantiateIsChest = newObj:IsA("Chest")
		end
	end

	local oldInstantiateIsPlayer = t.Player(last)
	local oldInstantiateIsGround = last == ""
	local oldInstantiateIsChest = type(last) == "string" and last ~= ""
	do
		if oldInstantiateIsChest then
			local lastobj = instancesManager.getObj(last :: string)
			oldInstantiateIsChest = lastobj:IsA("Chest")
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

function module.canAddToInventory(self: ClassType, inv: { any })
	if not inv then
		return false
	end

	if not inventorySharedUtil.canAddItem(inv, self.UID) then
		return false
	end

	return true, inv
end

function module.AddToInventory(self: ClassType, inv: { any }?, slot: number?)
	inv = inv or inventorySharedUtil.getPlayerInventory(self.InstantiatedTo)
	local success, inventory = self:canAddToInventory(inv)
	if not success then
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
	if not chest:IsA("Chest") then
		return false
	end

	self:InstantiateTo(chestUID, contentTabName)
	chest:AddItem(self.UID, contentTabName)
	return self
end

function module.RemoveFromChest(self: ClassType, chestUID: string)
	local chest = instancesManager.getObj(chestUID)
	if not chest:IsA("Chest") then
		return false
	end

	chest:RemoveItem(self.UID)
	return true
end

function module.RemoveFromInventory(self: ClassType, inv: { any })
	if not inv then
		return false
	end

	print("equipped: ", self.equipped)
	if self.equipped then
		self:UnequipItem()
	end

	-- Remove o item do inventário
	inventorySharedUtil.removeItem(inv, self.UID)
	return true
end

function module.ToggleEquip(self: ClassType, pos: number?)
	if self.equipped then
		self:UnequipItem(pos)
	else
		self:EquipItem()
	end
	return self
end

function module.EquipItem(self: ClassType)
	print("equipped", self.equipped)
	if self.equipped then
		return false
	end
	if not t.Player(self.InstantiatedTo) then
		return false
	end
	self.equipped = true
	print("equipped", self.equipped)

	return self
end

function module.UnequipItem(self: ClassType)
	print("equipped", self.equipped)
	if not self.equipped then
		return false
	end
	if not t.Player(self.InstantiatedTo) then
		return false
	end
	self.equipped = false
	print("equipped", self.equipped)

	return self
end

function module.ChangeUsage(self: ClassType, newUsage: number?)
	print(newUsage)
	print(self.Usage, self.MaxUsage, self.UsageDecreaseEachUse)
	if not self.Usage or not self.MaxUsage or not self.UsageDecreaseEachUse then
		return false
	end
	print()

	self.Usage = math.clamp(newUsage or self.Usage - self.UsageDecreaseEachUse, 0, self.MaxUsage)

	if 0 >= self.Usage then
		self:Destroy()
	end
	return true
end

function module.CanUseItem(self: ClassType, funcN: number)
	if not t.number(funcN) then
		return false
	end
	print()

	if
		not (self.UsageDecreaseEachUse and self.MaxUsage and self.Usage and (self.ItemFunction1 or self.ItemFunction2))
	then
		return false
	end
	print()

	if not self.equipped then
		return false
	end
	print()

	if not t.Player(self.InstantiatedTo) then
		return false
	end
	print()

	local funcName = "ItemFunction" .. funcN
	local func = self[funcName]

	if not func then
		return false
	end
	print()

	local success2 = func.CanUse(self)
	if not success2 then
		return false
	end
	print()

	return true
end

function module.UseItem(self: ClassType, funcN: number)
	local canUse = self:CanUseItem(funcN)
	if not canUse then
		return false
	end

	local funcName = "ItemFunction" .. funcN
	local func = self[funcName]

	if not func then
		return false
	end

	local success2 = func.UseItem(self)
	if not success2 then
		return false
	end

	return true
end

function module.Destroy(self: ClassType)
	self:InstantiateTo(nil)
	replicableInstance.Destroy(self)
	return true
end

return module
