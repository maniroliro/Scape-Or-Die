local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t

local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)
local charUtils = lib.FunctionUtils.Character

local wallSharedClass = require(sharedModules.Classes.DerivedClasses.WallClass)

local module = setmetatable({}, { __index = wallSharedClass })

export type ClassType = typeof(setmetatable({} :: {}, { __index = module })) & wallSharedClass.ClassType

function module.new(id: string | number?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, wallSharedClass) :: ClassType
	self.PlayersSearching = {}

	if id then
		self:AttachId(id)
	end
	return self
end

function module.Materialize(self: ClassType, Model: Model | BasePart?)
	-- Chama o método shared do ReplicableInstance primeiro
	local success = wallSharedClass.Materialize(self, Model)
	if not success then
		return self
	end

	-- Lógica específica do servidor
	self.Remote:Fire(self.UID, "Materialize", { self.Model })
	return self
end

function module.DestroyModel(self: ClassType)
	local success = wallSharedClass.DestroyModel(self)
	if not success then
		return self
	end

	self.Remote:Fire(self.UID, "DestroyModel", {})
	return self
end

function module.TakeDamage(self: ClassType, damage: number)
	local success = wallSharedClass.TakeDamage(self, damage)
	if not success then
		return self
	end

	self.Remote:Fire(self.UID, "TakeDamage", { damage })
	return self
end

function module.ReplicateTo(self: ClassType, client: Player?)
	local newwall = lib.Remotes.instanceCreated.Wall
	if client then
		newwall:FireClient(client, self.UID)

		self.Remote:FireClient(client, self.UID, "AttachId", { self.Id })
		self.Remote:FireClient(client, self.UID, "Materialize", { self.Model })
	else
		newwall:Fire(self.UID)
		self.Remote:Fire(self.UID, "AttachId", { self.Id })
		self.Remote:Fire(self.UID, "Materialize", { self.Model })
	end

	return self
end

return module
