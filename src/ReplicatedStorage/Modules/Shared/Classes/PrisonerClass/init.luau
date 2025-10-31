local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal
local charUtil = lib.FunctionUtils.Character

local sharedModules = replicatedStorage.Modules.Shared

local gameCharacterSharedClass = require(sharedModules.Classes.BaseClasses.GameCharacterClass)
local gameCharacterClass: gameCharacterSharedClass.ClassType = runService:IsServer()
		and require(game.ServerStorage.Modules.Classes.BaseClasses.GameCharacter)
	or require(replicatedStorage.Modules.Client.Replicas.GameCharacterReplica)

local directoryFolder = replicatedStorage.Directory
local prisonersDirectory = require(directoryFolder.Prisoners)

local module = {} --:: & replicableInstance.ClassType
local moduleClass = gameCharacterClass:newFromThis(module):ExtendType("Prisoner")

export type ClassType = prisonersDirectory.Type & gameCharacterSharedClass.ClassType & typeof(moduleClass) & {
	Inventory: { string },

	Heat: number,

	MaxStamina: number,
	Stamina: number,
	Intellect: number,
	Money: number,
}

function module.new(UID: string?): ClassType
	local self = gameCharacterClass.new(UID):AddInheritance(moduleClass)

	return self
end

return moduleClass
