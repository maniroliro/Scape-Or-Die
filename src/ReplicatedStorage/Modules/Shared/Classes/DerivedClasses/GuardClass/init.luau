local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal

local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local gameCharacterClass = require(sharedModules.Classes.BaseClasses.GameCharacterClass)

local directoryFolder = replicatedStorage.Directory
local guardDirectory = require(directoryFolder.Guards)

local module = setmetatable({}, { __index = gameCharacterClass }) --:: & replicableInstance.ClassType
module._Type = replicableInstance.extendType("Guard")

export type ClassType =
	typeof(setmetatable(
		{} :: {
			ChansingPrisoner: Player?,
		},
		{ __index = module }
	))
	& gameCharacterClass.ClassType
	& guardDirectory.Type

function module.new(UID: string | number?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, gameCharacterClass, UID) :: ClassType

	return self
end

function module.AttachId(self: ClassType, id: string)
	local sucess = replicableInstance.AttachId(self, id)
	if not sucess then
		return false
	end

	if self.Health and self.MaxHealth then
		self.Health = self.Health
	end
	return self
end

function module.Materialize(self: ClassType, spawnCFrame: CFrame?)
	if self.Character then
		return false
	end

	local success = replicableInstance.Materialize(self, spawnCFrame)
	if not success then
		return false
	end

	self.Character = self.Model
	self.Model = nil

	return self
end

return module
