local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal
local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local gameCharacterSharedClass = require(sharedModules.Classes.BaseClasses.GameCharacterClass)

local module = {}
local moduleClass = gameCharacterSharedClass:newFromThis(module)

export type ClassType = typeof(setmetatable({} :: {}, { __index = module })) & gameCharacterSharedClass.ClassType

function module.new(UID: string?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, gameCharacterSharedClass.new(UID))

	return self
end

function module.KnockDown(self: ClassType)
	return self
end

return moduleClass
