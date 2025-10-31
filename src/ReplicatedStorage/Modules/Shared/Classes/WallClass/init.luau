local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = replicatedStorage.Modules.Shared
local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local jailComponentClass = require(sharedModules.Classes.BaseClasses.JailComponentClass)

local directoryFolder = replicatedStorage.Directory

local wallsDirectory = require(directoryFolder.Walls)

-- local module = setmetatable({}, { __index = jailComponentClass })
-- module._Type = replicableInstance.ExtendType("Wall", jailComponentClass._Type)

local module = {}
local moduleClass = replicableInstance:newFromThis(module):AddInheritance(jailComponentClass):ExtendType("Wall")

export type ClassType = jailComponentClass.ClassType & wallsDirectory.Type & typeof(moduleClass) & {
	Model: Model,
	CFrame: CFrame,
}

function module.new(UID: string?): ClassType
	-- local self = replicableInstance.newLinkedToAClass(module, jailComponentClass.new(UID)) :: ClassType
	local self = replicableInstance.new(UID):AddInheritance(jailComponentClass.new()):AddInheritance(moduleClass)

	return self
end

function module.Materialize(self: ClassType, info: replicableInstance.MaterializeInfo)
	local success = jailComponentClass.Materialize(self, info)
	if not success then
		return false
	end

	self.Model.Parent = workspace

	return self
end

function module.AttachId(self: ClassType, id: number)
	local success = jailComponentClass.AttachId(self, id)
	if not success then
		return false
	end

	return self
end

return moduleClass
