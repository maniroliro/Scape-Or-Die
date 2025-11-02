local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal
local replicableInstanceClass = require(sharedModules.Classes.BaseClasses.ReplicableInstanceClass)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local gameCharacterSharedClass = require(sharedModules.Classes.BaseClasses.GameCharacterClass)

-- local module = setmetatable({}, { __index = gameCharacterSharedClass }) --:: & replicableInstanceClass.ClassType
-- setmetatable(module, { __index = gameCharacterSharedClass })
local module = {}
local moduleClass = replicableInstanceClass:newFromThis(module):AddInheritance(gameCharacterSharedClass)

export type ClassType = gameCharacterSharedClass.ClassType & typeof(moduleClass) & {}

function module.new(UID: string?): ClassType
	local self = gameCharacterSharedClass.new(UID):AddInheritance(moduleClass)

	return self
end

function module.KnockDown(self: ClassType)
	return self
end

function module.ReplicateTo(self: ClassType, client: Player?)
	local newGameCharacter = lib.Remotes.instanceCreated
	if client then
		newGameCharacter:FireClient(client, self.ClassName, self.UID)

		self.Remote:FireClient(client, self.UID, "AttachId", { self.Id })

		if self.KnockedDown then
			self.Remote:FireClient(client, self.UID, "KnockDown", {})
		end

		self.Remote:FireClient(client, self.UID, "SetController", { self.ControlledBy })
	else
		newGameCharacter:Fire(self.ClassName, self.UID)
		self.Remote:Fire(self.UID, "AttachId", { self.Id })

		if self.KnockedDown then
			self.Remote:Fire(self.UID, "KnockDown", {})
		end

		self.Remote:Fire(self.UID, "SetController", { self.ControlledBy })
	end

	return self
end

return moduleClass
