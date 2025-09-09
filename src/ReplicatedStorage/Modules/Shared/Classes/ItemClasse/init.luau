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

export type ClassType = typeof(setmetatable(
	{} :: {
		PlayerOwner: Player?,
		CFrame: CFrame?,
		equipped: boolean,
		InstantiatedTo: string | Player,
	},
	{ __index = module }
)) & itemsDirectory.Type & replicableInstance.ClassType

function module.new(id: string | number?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, replicableInstance) :: ClassType
	self._Type = "Item"
	self.equipped = false

	if id then
		self:AttachId(id)
	end
	return self
end

function module.Materialize(self: ClassType, CF: CFrame)
	if not t.CFrame(CF) then
		return self
	end

	self.CFrame = lib.Utils.GetLegalCFrame(CF)
	return self
end

function module.InstantiateTo(self: ClassType, any: string | Player, ...)
	if self.InstantiatedTo == any then
		return self
	end
	self.InstantiatedTo = any

	return self
end

function module.Drop(self: ClassType)
	local cf = t.Player(self.InstantiatedTo) and charUtil.getAlivePlayerRootPart(self.InstantiatedTo).CFrame or self.InstantiatedTo.CFrame
	self.CFrame = cf * CFrame.new(0, -3, 0)
	self:InstantiateTo("")

	return self
end

function module.SetOwner(self: ClassType, plr: Player?)
	if not t.Player(plr) then
		return self
	end

	self.PlayerOwner = plr
	return self
end

function module.AddToInventory(self: ClassType, inv: { any }?, slot: number?)
	local plr = self.InstantiatedTo
	if not t.Player(plr) then
		return self
	end
	local inventory = inv or inventorySharedUtil.getPlayerInventory(plr)
	if not inventory then
		return self
	end
	if inventorySharedUtil.canAddItem(inventory, self.UID) then
		print(self.InstantiatedTo)
		self:TryToInstantiateTo(plr)
		print(self.InstantiatedTo)
		slot = slot or inventorySharedUtil.getNextSlotForANewItem(inventory)

		inventorySharedUtil.addItemToInventory(self.UID, inventory, slot)
	end

	return self
end

function module.AddToChest(self: ClassType, chestUID: string, contentTabName: string?)
	self:TryToInstantiateTo(chestUID, contentTabName)
	local chest = instancesManager.getObj(chestUID)
	if chest and chest._Type == "Chest" then
		chest:AddItem(self.UID, contentTabName)
	end
	return self
end

function module.RemoveFromChest(self: ClassType)
	local chest = instancesManager.getObj(self.InstantiatedTo)
	if chest and chest._Type == "Chest" then
		chest:RemoveItem(self.UID)
	end
	return self
end

function module.TryToInstantiateTo(self: ClassType, any: string | Player, chestStorage: string?)
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

	local last = self.InstantiatedTo
	self:InstantiateTo(any)
	if isGround then
		self:Drop()
	elseif isChest then
		local chest = instancesManager.getObj(any :: string)
		if chest and chest._Type == "Chest" then
			self:AddToChest(any :: string, chestStorage)
		end
	elseif isPlayer then
		self:AddToInventory()
		local chest = instancesManager.getObj(last)
		if chest then
			self:RemoveFromChest()
		end
	end
	
	return self
end

return module
