local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal
local simpleZone = lib.ModuleUtils.Zone

local replicableInstanceClass = require(sharedModules.Classes.BaseClasses.ReplicableInstanceClass)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local directoryFolder = replicatedStorage.Directory

-- local module = setmetatable({}, { __index = replicableInstanceClass }) --:: & replicableInstanceClass.ClassType
-- module._Type = replicableInstanceClass.ExtendType("PrisonArea")

local module = {}
local moduleClass = replicableInstanceClass:newFromThis(module):ExtendType("PrisonArea")

export type ClassType = & replicableInstanceClass.ClassType & typeof(moduleClass) & {
	Areas: { BasePart }, -- typeof(replicatedStorage.Assets.Directory.Chests["00 _ Template"].Model),
	GameCharacterEnteredArea: lib.Signal<nil, Model, BasePart>,
	GameCharacterExitedArea: lib.Signal<nil, Model, BasePart>,
}

function module.new(UID: string?): ClassType
	-- local self = replicableInstanceClass.newLinkedToAClass(module, replicableInstanceClass.new(UID))
	local self = replicableInstanceClass.new(UID):AddInheritance(moduleClass)
	self.Areas = {}
	--self.AreasConnection = {}
	self.GameCharacterEnteredArea = self.Trove:Construct(signal)
	self.GameCharacterExitedArea = self.Trove:Construct(signal)

	--simpleZone.SimpleZone.fromParts({parts})

	return self
end

function module.ExtendArea(self: ClassType, areaPart: BasePart)
	if not t.instanceIsA("BasePart")(areaPart) then
		return false
	end

	table.insert(self.Areas, areaPart)

	return self
end

return moduleClass
