local replicatedStorage = game:GetService("ReplicatedStorage")

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal
local zone = lib.ModuleUtils.Zone

local sharedModules = replicatedStorage.Modules.Shared
local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local livingClass = require(sharedModules.Classes.BaseClasses.LivingClass)

local module = {}
local moduleClass = replicableInstance:newFromThis(module):AddInheritance(livingClass):ExtendType("JailComponent")

export type ClassType = replicableInstance.ClassType & typeof(moduleClass) & {
	--CanBeBroken: boolean,
	CanBeFaked: boolean,

	HealthChanged: lib.Signal<nil, number>,
	Health: number,
	MaxHealth: number,

	CFrame: CFrame,
	Model: Model,
}

function module.new(UID: string?): ClassType
	local self = replicableInstance.new(UID):AddInheritance(livingClass.new()):AddInheritance(moduleClass)
	--local self = replicableInstance.newLinkedToAClass(module, replicableInstance.new(UID)) :: ClassType

	return self
end

function module.AttachId(self: ClassType, id: number)
	local sucess = replicableInstance.AttachId(self, id)
	if not sucess then
		return false
	end

	if self.Health and self.MaxHealth then
		self.Health = self.Health
		self.HealthChanged = signal.new()
	end

	self.Id = id
	return self
end

function module.Materialize(self: ClassType, info: replicableInstance.MaterializeInfo)
	local success = replicableInstance.Materialize(self, info)
	if not success then
		return false
	end

	return self
end

-- function module._SetHealth(self: ClassType, health: number)
-- 	if health == self.Health then
-- 		return self
-- 	end

-- 	local maxHealth = self.MaxHealth

-- 	if health <= 0 then
-- 		self.Health = 0
-- 		self.HealthChanged:Fire(self.Health)
-- 		self:DestroyModel()
-- 		return self
-- 	end

-- 	if health > maxHealth then
-- 		health = maxHealth
-- 	end
-- 	self.Health = health

-- 	self.HealthChanged:Fire(self.Health)
-- 	return self
-- end

-- function module.TakeDamage(self: ClassType, damage: number)
-- 	local health = self.Health
-- 	if health <= 0 then
-- 		return false
-- 	end

-- 	health -= damage
-- 	self:_SetHealth(health)

-- 	return self
-- end

function module.Repair(self: ClassType, amount: number)
	local health = self.Health
	local maxHealth = self.MaxHealth

	amount = amount or maxHealth
	self:_SetHealth(health)

	return self
end

function module.DestroyModel(self: ClassType)
	local model: Part = self.Model
	if not model then
		return false
	end

	self:TakeDamage(self.Health)

	if model:IsA("BasePart") then
		model.Transparency = 1
		model.CanCollide = false
	end

	for _, part in self.Model:GetDescendants() do
		if part:IsA("BasePart") then
			if part.Transparency then
				part.Transparency = 1
				part.CanCollide = false
			end
		end
	end

	return self
end

function module.BuildModel(self: ClassType)
	if 0 >= self.Health then
		return false
	end

	if self.Model:IsA("BasePart") then
		self.Model.Transparency = 0
		self.Model.CanCollide = true
	end

	for _, part in self.Model:GetDescendants() do
		if part:IsA("BasePart") then
			if part.Transparency then
				part.Transparency = 0
				part.CanCollide = true
			end
		end
	end

	return self
end

return moduleClass
