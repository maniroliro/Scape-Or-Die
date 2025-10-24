local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal
local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local gameCharacterSharedClass = require(sharedModules.Classes.BaseClasses.GameCharacterClass)

local module = setmetatable({}, { __index = gameCharacterSharedClass }) --:: & replicableInstance.ClassType
setmetatable(module, { __index = gameCharacterSharedClass })

export type ClassType = typeof(setmetatable({} :: {}, { __index = module })) & gameCharacterSharedClass.ClassType

function module.new(UID: string?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, gameCharacterSharedClass.new(UID))

	return self
end

function module.KnockDown(self: ClassType)
	return self
end

function module.ReplicateTo(self: ClassType, client: Player?)
	local newchest = lib.Remotes.instanceCreated.Chest
	if client then
		newchest:FireClient(client, self.UID)

		self.Remote:FireClient(client, self.UID, "AttachId", { self.Id })
		self.Remote:FireClient(client, self.UID, "SetOwner", { self.PlayerOwner })
		self.Remote:FireClient(client, self.UID, "Materialize", { self.CFrame })
	else
		newchest:Fire(self.UID)
		self.Remote:Fire(self.UID, "AttachId", { self.Id })
		self.Remote:Fire(self.UID, "SetOwner", { self.PlayerOwner })
		self.Remote:Fire(self.UID, "Materialize", { self.CFrame })
	end

	return self
end

return module
