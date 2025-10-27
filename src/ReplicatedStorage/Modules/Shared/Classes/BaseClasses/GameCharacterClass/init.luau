local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local tableUtils = lib.FunctionUtils.Table
local signal = lib.ModuleUtils.Signal
local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local livingClass = require(sharedModules.Classes.BaseClasses.LivingClass)

local directoryFolder = replicatedStorage.Directory

local baseClass = require(sharedModules.Classes.BaseClasses.BaseClass)

local module = baseClass.new():AddInheritance(replicableInstance):AddInheritance(livingClass)
module:ExtendType("GameCharacter")

module.

local moduleTest = replicableInstance:newFromThis():AddInheritance(livingClass)
moduleTest:ExtendType('GameCharacter')

moduleTest.

-- module = setmetatable(replicableInstance:ExtendType("GameCharacter"), {
-- 	__index = function(_, k): livingClass.ClassType --typeof(replicableInstance)-- & livingClass.ClassType
-- 		return replicableInstance[k] or livingClass[k]
-- 	end,
-- })

-- export type ClassType = replicableInstance.ClassType<
-- 	typeof(setmetatable(
-- 		{} :: {
-- 			Character: Model?,
-- 			KnockedDown: boolean,
-- 			ControlledBy: (Player | string)?, -- PlayerInstance or 'AI'

-- 			Outfit: "Prisoner" | "Guard" | "Undressed",
-- 			Fitness: number,
-- 			Strength: number,
-- 		},
-- 		{ __index = module }
-- 	))
-- >

export type ClassType =
	typeof(setmetatable(
		{} :: {
			Character: Model?,
			KnockedDown: boolean,
			ControlledBy: (Player | string)?, -- PlayerInstance or 'AI'

			Outfit: "Prisoner" | "Guard" | "Undressed",
			Fitness: number,
			Strength: number,
		},
		{ __index = module }
	))
	& replicableInstance.ClassType
	& livingClass.ClassType

function module.new(UID: string?): ClassType
	--local self = replicableInstance.new()
	--self = self:AddInheritance(module)
	--self = self:AddInheritance(livingClass.new(self))

	local self = replicableInstance.new(UID):AddInheritance(module)

	-- local self = replicableInstance.newLinkedToAClass(module, replicableInstance.new(UID))
	-- self = replicableInstance.newLinkedToAClass(self, livingClass.new(self))

	print("asdasdasd", self.HealthChanged)

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

function module.KnockDown(self: ClassType)
	if self.Character then
		self:TakeDamage(self.Health)
	end
	return self
end

return module
