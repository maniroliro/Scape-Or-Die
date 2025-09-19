local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = replicatedStorage.Modules.Shared
local replicableInstance = require(sharedModules.Classes.ReplicableInstance)

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal

local directoryFolder = replicatedStorage.Directory

local wallsDirectory = require(directoryFolder.Walls)

local module = setmetatable({}, { __index = replicableInstance }) --:: & replicableInstance.ClassType
module._Type = "Wall"

export type ClassType =
	typeof(setmetatable(
		{} :: {
			CFrame: CFrame,
			Model: Model,

			HealthChanged: lib.Signal<nil, number>,
		},
		{ __index = module }
	))
	& replicableInstance.ClassType
	& wallsDirectory.Type

function module.new(UID: string | number?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, replicableInstance, UID) :: ClassType
	self.HealthChanged = signal.new()

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
