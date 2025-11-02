local replicatedStorage = game:GetService("ReplicatedStorage")

local lib = require(replicatedStorage.lib)

local sharedModules = replicatedStorage.Modules.Shared
local replicableInstanceClass = require(sharedModules.Classes.BaseClasses.ReplicableInstanceClass)
local securityCameraSharedClass = require(sharedModules.Classes.SecurityCameraClass)

-- local module = setmetatable({}, { __index = securityCameraSharedClass })
-- module.__index = module

local module = {}
local moduleClass = securityCameraSharedClass:newFromThis(module)

export type ClassType = securityCameraSharedClass.ClassType & typeof(moduleClass) & {
	--Support: typeof(module.Model.Support) & BasePart,
}

function module.new(UID: string): ClassType
	-- local self: ClassType = replicableInstanceClass.newLinkedToAClass(module, securityCameraSharedClass.new(UID)) :: ClassType
	local self = securityCameraSharedClass.new(UID):AddInheritance(moduleClass)

	return self
end

function module.Materialize(self: ClassType, wallUID: string)
	local success = securityCameraSharedClass.Materialize(self, wallUID)
	if not success then
		return self
	end

	return self
end

function module.Active(self: ClassType, active: boolean?)
	local success = securityCameraSharedClass.Active(self, active)
	if not success then
		return self
	end

	return self
end

return moduleClass
