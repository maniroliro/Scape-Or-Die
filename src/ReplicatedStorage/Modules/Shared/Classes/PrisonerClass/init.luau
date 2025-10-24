local replicatedStorage = game:GetService("ReplicatedStorage")

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal
local charUtil = lib.FunctionUtils.Character

local sharedModules = replicatedStorage.Modules.Shared

local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local gameCharacterClass = require(sharedModules.Classes.BaseClasses.GameCharacterClass)

local inventorySharedUtil = require(sharedModules.Utils.InventoryUtilShared)

local directoryFolder = replicatedStorage.Directory

local module = setmetatable({}, { __index = gameCharacterClass }) --:: & replicableInstance.ClassType
module._Type = replicableInstance.ExtendType("Prisoner")

export type ClassType =
	typeof(setmetatable(
		{} :: {
			Inventory: { string },

			Heat: number,
			Stamina: number,
			Intellect: number,
			Money: number,
		},
		{ __index = module }
	))
	& gameCharacterClass.ClassType

function module.new(UID: string?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, gameCharacterClass.new(UID)) :: ClassType

	return self
end
