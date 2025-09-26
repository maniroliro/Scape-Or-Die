local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = replicatedStorage.Modules.Shared
local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local jailComponentClass = require(sharedModules.Classes.BaseClasses.JailComponentClass)

local directoryFolder = replicatedStorage.Directory

local wallsDirectory = require(directoryFolder.Walls)

local module = setmetatable({}, { __index = jailComponentClass })
module._Type = replicableInstance.extendType("Wall", jailComponentClass._Type)

export type ClassType =
	typeof(setmetatable(
		{} :: {
			Model: Model,
			CFrame: CFrame,
		},
		{ __index = module }
	))
	& jailComponentClass.ClassType
	& wallsDirectory.Type

function module.new(UID: string | number?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, jailComponentClass, UID) :: ClassType

	return self
end

function module.Materialize(self: ClassType, CF: CFrame)
	local success = jailComponentClass.Materialize(self, CF)
	if not success then
		return false
	end

	self.Model.Parent = workspace

	return self
end

function module.AttachId(self: ClassType, id: string)
	local success = jailComponentClass.AttachId(self, id)
	if not success then
		return false
	end

	return self
end

return module
