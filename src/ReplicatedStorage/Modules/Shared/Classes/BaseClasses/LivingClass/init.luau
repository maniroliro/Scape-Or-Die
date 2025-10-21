local replicatedStorage = game:GetService("ReplicatedStorage")

local lib = require(replicatedStorage.lib)
local signal = lib.ModuleUtils.Signal

local module = {}

export type ClassType<T = { any }> = typeof(setmetatable(
	{} :: {
		Health: number,
		MaxHealth: number,

		HealthChanged: lib.Signal<nil, number>,
	} & T,
	{ __index = module }
))

function module.new<T>(obj: T?): ClassType<T>
	local self = setmetatable(obj or {} :: any, { __index = module }) :: ClassType<T>
	self.Health = 100
	self.MaxHealth = 100
	self.HealthChanged = signal.new()
	return self
end

function module._SetHealth<T>(self: ClassType<T>, health: number)
	if health == self.Health then
		return self
	end

	local maxHealth = self.MaxHealth

	if health <= 0 then
		self.Health = 0
		self.HealthChanged:Fire(self.Health)
		return self
	end

	if health > maxHealth then
		health = maxHealth
	end
	self.Health = health

	self.HealthChanged:Fire(self.Health)
	return self
end

function module.TakeDamage<T>(self: ClassType<T>, damage: number)
	local health = self.Health
	if health <= 0 then
		return false
	end

	health -= damage
	self:_SetHealth(health)

	return self
end

return module
