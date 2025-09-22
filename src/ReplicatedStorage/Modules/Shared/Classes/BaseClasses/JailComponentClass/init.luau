local ReplicatedStorage = game:GetService("ReplicatedStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")

local FastCastTypes = require(ReplicatedStorage.lib.lib.ModuleUtils._FastCastRedux.FastCastTypes)
local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal
local zone = lib.ModuleUtils.Zone

local sharedModules = replicatedStorage.Modules.Shared
local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)

local module = setmetatable({}, { __index = replicableInstance }) --:: & replicableInstance.ClassType
module._Type = "JailComponent"

export type ClassType =
	typeof(setmetatable(
		{} :: {
			--CanBeBroken: boolean,
			CanBeFaked: boolean,

			HealthChanged: lib.Signal<nil, number>,
			Health: number,
			MaxHealth: number,

			CFrame: CFrame,
			Model: Model,
		},
		{ __index = module }
	))
	& replicableInstance.ClassType

function module.new(UID: string | number?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, replicableInstance, UID) :: ClassType

	return self
end

function module.AttachId(self: ClassType, id: string)
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

function module.Materialize(self: ClassType, CF: CFrame)
	local success = replicableInstance.Materialize(self, CF)
	if not success then
		return false
	end

	return self
end

function module._SetHealth(self: ClassType, health: number)
	local maxHealth = self.MaxHealth

	if health <= 0 then
		self.Health = 0
		self.HealthChanged:Fire(self.Health)
		self:DestroyModel()
		return self
	end

	if health > maxHealth then
		health = maxHealth
	end
	self.Health = health

	self.HealthChanged:Fire(self.Health)
	return self
end

function module.TakeDamage(self: ClassType, damage: number)
	local health = self.Health
	if health <= 0 then
		return false
	end

	health -= damage
	self:_SetHealth(health)

	return self
end

function module.Repair(self: ClassType, amount: number)
	local health = self.Health
	local maxHealth = self.MaxHealth

	amount = amount or maxHealth
	-- if health <= 0 then
	-- 	return false
	-- end

	health += amount
	if health > maxHealth then
		health = maxHealth
	end
	self:_SetHealth(health)

	return self
end

function module.DestroyModel(self: ClassType)
	if not self.Model then
		return false
	end

	self:_SetHealth(0)

	for _, part in self.Model:GetDescendants() do
		if part:IsA("BasePart") then
			if part.Transparency then
				part.Transparency = 1
			end
		end
	end

	return self
end

function module.BuildModel(self: ClassType)
	if 0 >= self.Health then
		return false
	end

	for _, part in self.Model:GetDescendants() do
		if part:IsA("BasePart") then
			if part.Transparency then
				part.Transparency = 0
			end
		end
	end

	return self
end

return module
