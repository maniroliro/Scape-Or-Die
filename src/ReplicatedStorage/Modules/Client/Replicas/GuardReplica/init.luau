local replicatedStorage = game:GetService("ReplicatedStorage")

local lib = require(replicatedStorage.lib)

local sharedModules = replicatedStorage.Modules.Shared
local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local guardSharedClass = require(sharedModules.Classes.GuardClass)
local gameCharacterReplica = require(replicatedStorage.Modules.Client.Replicas.GameCharacterReplica)

local module = {}
local moduleClass = gameCharacterReplica:newFromThis(module)

export type ClassType = guardSharedClass.ClassType & gameCharacterReplica.ClassType & typeof(moduleClass) & {}

function module.new(UID: string?): ClassType
	local self = gameCharacterReplica.new(UID):AddInheritance(moduleClass)

	return self
end

return moduleClass
