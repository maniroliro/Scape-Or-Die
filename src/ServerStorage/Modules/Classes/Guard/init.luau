local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal
local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local guardSharedClass = require(sharedModules.Classes.DerivedClasses.GuardClass)

local module = setmetatable({}, { __index = replicableInstance }) --:: & replicableInstance.ClassType
module._Type = replicableInstance.extendType("Guard")

export type ClassType =
	typeof(setmetatable(
		{} :: {
			Character: Model?,
			ChansingPrisoner: Player?,

			HealthChanged: lib.Signal<nil, number>,
		},
		{ __index = module }
	))
	& guardSharedClass.ClassType

function module.new(id: string | number?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, guardSharedClass) :: ClassType
	self.HealthChanged = signal.new()

	if id then
		self:AttachId(id)
	end
	return self
end

function module.Materialize(self: ClassType, spawnCFrame: CFrame?)
	local success = guardSharedClass.Materialize(self, spawnCFrame)
	if not success then
		return false
	end

	return self
end

return module
