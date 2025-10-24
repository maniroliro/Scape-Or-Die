local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local sharedModules = replicatedStorage.Modules.Shared

local BaseClass = require(sharedModules.Classes.BaseClasses.BaseClass)
local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal

local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local gameCharacterSharedClass = require(sharedModules.Classes.BaseClasses.GameCharacterClass)
local gameCharacterClass = runService:IsServer()
		and require(game.ServerStorage.Modules.Classes.BaseClasses.GameCharacter)
	or require(replicatedStorage.Modules.Client.Replicas.GameCharacterReplica)

local directoryFolder = replicatedStorage.Directory
local guardDirectory = require(directoryFolder.Guards)

local module = setmetatable({}, { __index = gameCharacterClass }) --:: & replicableInstance.ClassType
module._Type = replicableInstance.ExtendType("Guard")

export type ClassType =
	typeof(setmetatable(
		{} :: {
			ChansingPrisoner: Player?,
		},
		{ __index = module }
	))
	& gameCharacterSharedClass.ClassType
	& guardDirectory.Type

function module.new(UID: string?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, gameCharacterClass.new(UID)) :: ClassType

	return self
end

function module.AttachId(self: ClassType, id: number)
	local sucess = replicableInstance.AttachId(self, id)
	if not sucess then
		return false
	end

	if self.Health and self.MaxHealth then
		self.Health = self.Health
	end
	return self
end

function module.Materialize(self: ClassType, info: replicableInstance.MaterializeInfo)
	if self.Character then
		return false
	end

	local success = replicableInstance.Materialize(self, info)
	if not success then
		return false
	end

	self.Character = self.Model
	self.Model = nil

	return self
end

return module
