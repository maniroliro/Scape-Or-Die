local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal
local simpleZone = lib.ModuleUtils.Zone

local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local directoryFolder = replicatedStorage.Directory

local module = setmetatable({}, { __index = replicableInstance }) --:: & replicableInstance.ClassType
module._Type = replicableInstance.extendType("PrisonArea")

export type ClassType =
	typeof(setmetatable(
		{} :: {
			Areas: { BasePart }, -- typeof(replicatedStorage.Assets.Directory.Chests["00 _ Template"].Model),
			GameCharacterEnteredArea: lib.Signal<nil, Model, BasePart>,
			GameCharacterExitedArea: lib.Signal<nil, Model, BasePart>,
		},
		{ __index = module }
	))
	& replicableInstance.ClassType

function module.new(UID: string?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, replicableInstance.new(UID))
	self.Areas = {}
	self.AreasConnection = {}
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

return module
