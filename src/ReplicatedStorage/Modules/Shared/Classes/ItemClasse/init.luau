local replicatedStorage = game:GetService("ReplicatedStorage")

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t

local sharedModules = replicatedStorage.Modules.Shared

local replicableInstance = require(sharedModules.Classes.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local inventoryUtil = require(sharedModules.Utils.InventoryUtilShared)

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
)) & replicableInstance.ClassType & itemsDirectory.Type

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
	if self.InstantiatedTo ~= "" then
		-- player? player cf + ...
		self.CFrame = sel
		self:InstantiateTo("")
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
