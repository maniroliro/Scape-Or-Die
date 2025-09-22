local replicatedStorage = game:GetService("ReplicatedStorage")

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local charUtil = lib.FunctionUtils.Character

local sharedModules = replicatedStorage.Modules.Shared

local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local module = setmetatable({}, { __index = replicableInstance }) --:: & replicableInstance.ClassType
module._Type = "Ground"

export type ClassType = typeof(setmetatable(
	{} :: {
		items: { [string]: CFrame },
	},
	{ __index = module }
)) & replicableInstance.ClassType

function module.new(UID: string | number?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, replicableInstance, UID) :: ClassType
	self.items = {}

	return self
end

function module.canToAddItem(self: ClassType, itemUID: string, CF: CFrame)
	if not t.CFrame(CF) or not t.string(itemUID) then
		return false
	end
	CF = lib.Utils.GetLegalCFrame(CF)

	local items = self.items
	if items[itemUID] then
		return false
	end

	for _, cf in items do
		if cf == CF then
			return false
		end
	end

	return true
end

function module.AddItem(self: ClassType, itemUID: string, CF: CFrame)
	if not t.CFrame(CF) or not t.string(itemUID) then
		return false
	end
	CF = lib.Utils.GetLegalCFrame(CF)
	if not self:canToAddItem(itemUID, CF) then
		return false
	end

	local items = self.items
	items[itemUID] = CF
	return true
end

function module.RemoveItem(self: ClassType, itemUID: string)
	if not t.string(itemUID) then
		return false
	end

	local items = self.items
	if not items[itemUID] then
		return false
	end

	items[itemUID] = nil
	return true
end

return module
