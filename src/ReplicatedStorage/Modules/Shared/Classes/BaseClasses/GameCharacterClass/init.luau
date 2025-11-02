local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local tableUtils = lib.FunctionUtils.Table
local signal = lib.ModuleUtils.Signal
local replicableInstanceClass = require(sharedModules.Classes.BaseClasses.ReplicableInstanceClass)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local livingClass = require(sharedModules.Classes.BaseClasses.LivingClass)

local module = {}
local moduleClass = replicableInstanceClass:newFromThis(module):AddInheritance(livingClass):ExtendType("GameCharacter")
-- module = setmetatable(replicableInstanceClass:ExtendType("GameCharacter"), {
-- 	__index = function(_, k): livingClass.ClassType --typeof(replicableInstanceClass)-- & livingClass.ClassType
-- 		return replicableInstanceClass[k] or livingClass[k]
-- 	end,
-- })

-- export type ClassType = replicableInstanceClass.ClassType<
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

-- export type ClassType =
-- 	typeof(setmetatable(
-- 		{} :: {
-- 			Character: Model?,
-- 			KnockedDown: boolean,
-- 			ControlledBy: (Player | string)?, -- PlayerInstance or 'AI'

-- 			Outfit: "Prisoner" | "Guard" | "Undressed",
-- 			Fitness: number,
-- 			Strength: number,
-- 		},
-- 		{ __index = moduleClass }
-- 	))
-- 	& typeof(moduleClass)

export type ClassType = typeof(moduleClass) & replicableInstanceClass.ClassType & {
	Character: Model?,
	KnockedDown: boolean,
	ControlledBy: (Player | string)?, -- PlayerInstance or 'AI'

	ChestOpen: string | boolean,

	Outfit: "Prisoner" | "Guard" | "Undressed",
	Fitness: number,
	Strength: number,
}

function module.new(UID: string?): ClassType
	--local self = replicableInstanceClass.new()
	--self = self:AddInheritance(module)
	--self = self:AddInheritance(livingClass.new(self))

	local self = replicableInstanceClass.new(UID):AddInheritance(livingClass.new()):AddInheritance(moduleClass)
	self.KnockedDown = false
	self.ChestOpen = false

	-- local self = replicableInstanceClass.newLinkedToAClass(module, replicableInstanceClass.new(UID))
	-- self = replicableInstanceClass.newLinkedToAClass(self, livingClass.new(self))

	print("asdasdasd", self.HealthChanged)

	return self
end

function module.AttachId(self: ClassType, id: number)
	local sucess = replicableInstanceClass.AttachId(self, id)
	if not sucess then
		return false
	end

	if self.Health and self.MaxHealth then
		self.Health = self.Health
	end
	return self
end

function module.Materialize(self: ClassType, info: replicableInstanceClass.MaterializeInfo)
	if self.Character then
		return false
	end

	local success = replicableInstanceClass.Materialize(self, info)
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

function module.CloseChest(self: ClassType)
	local chestOpen = self.ChestOpen
	if not chestOpen then
		return false
	end

	local chest = instancesManager.getObj(chestOpen)
	if not chest then
		return false
	end

	self.ChestOpen = false
	chest:CloseChest()
	return self
end

function module.OpenChest(self: ClassType, chest: instancesManager.InstanceArgsType)
	local instance = instancesManager.getObj(chest)
	if not instance or not instance:IsA("Chest") then
		return false
	end

	self.ChestOpen = instance.UID
	instance:TryToOpenChest(self.UID)
	return self
end

function module.TryToOpenChest(self: ClassType, chest: instancesManager.InstanceArgsType)
	if self.ChestOpen then
		return false
	end

	local instance = instancesManager.getObj(chest)
	if not instance or not instance:IsA("Chest") then
		return false
	end
	self:OpenChest(chest)
	return self
end

function module.SetController(self: ClassType, controller: Player | string)
	self.ControlledBy = controller
	return self
end

return moduleClass
