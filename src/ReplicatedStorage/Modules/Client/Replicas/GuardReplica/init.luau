local replicatedStorage = game:GetService("ReplicatedStorage")

local lib = require(replicatedStorage.lib)

local sharedModules = replicatedStorage.Modules.Shared
local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local guardSharedClass = require(sharedModules.Classes.GuardClass)
local gameCharacterReplica = require(replicatedStorage.Modules.Client.Replicas.GameCharacterReplica)

local module = setmetatable({}, { __index = guardSharedClass }) --:: & replicableInstance.ClassType

export type ClassType =
	typeof(setmetatable({} :: {}, { __index = module }))
	& guardSharedClass.ClassType
	& gameCharacterReplica.ClassType

function module.new(UID: string?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, guardSharedClass.new(UID)) :: ClassType

	return self
end
