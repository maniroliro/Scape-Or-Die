local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal
local charUtil = lib.FunctionUtils.Character

local sharedModules = replicatedStorage.Modules.Shared

local gameCharacterSharedClass = require(sharedModules.Classes.BaseClasses.GameCharacterClass)

local module = {}
local moduleClass = gameCharacterSharedClass:newFromThis(module)

export type ClassType = gameCharacterSharedClass.ClassType & typeof(moduleClass) & {}

function module.new(UID: string?): ClassType
	local self = gameCharacterSharedClass.new(UID):AddInheritance(moduleClass)

	return self
end

return moduleClass
