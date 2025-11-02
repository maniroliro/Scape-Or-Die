local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal
local simpleZone = lib.ModuleUtils.Zone

local replicableInstanceClass = require(sharedModules.Classes.BaseClasses.ReplicableInstanceClass)
local instancesManager = require(sharedModules.Managers.InstancesManager)
local prisonAreaClass = require(sharedModules.Classes.BaseClasses.PrisonAreaClass)

local directoryFolder = replicatedStorage.Directory

-- local module = setmetatable({}, { __index = replicableInstanceClass }) --:: & replicableInstanceClass.ClassType
-- module._Type = replicableInstanceClass.ExtendType("PrisonArea")

local module = {}
local moduleClass = prisonAreaClass:newFromThis(module)

export type ClassType = prisonAreaClass.ClassType & typeof(moduleClass) & {}

function module.new(UID: string?): ClassType
	local self = replicableInstanceClass.newLinkedToAClass(module, replicableInstanceClass.new(UID))

	return self
end

return moduleClass
