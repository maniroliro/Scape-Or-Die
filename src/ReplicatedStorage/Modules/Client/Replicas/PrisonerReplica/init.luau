local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")
local runService = game:GetService("RunService")

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal
local charUtil = lib.FunctionUtils.Character

local sharedModules = replicatedStorage.Modules.Shared

local prisonerSharedClass = require(sharedModules.Classes.PrisonerClass)

local module = {}
local moduleClass = prisonerSharedClass:newFromThis(module)

export type ClassType = prisonerSharedClass.ClassType & typeof(moduleClass) & {}

function module.new(UID: string?): ClassType
	local self = prisonerSharedClass.new(UID):AddInheritance(moduleClass)

	return self
end

return moduleClass
