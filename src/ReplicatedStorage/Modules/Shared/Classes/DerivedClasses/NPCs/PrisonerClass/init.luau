local replicatedStorage = game:GetService("ReplicatedStorage")

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal
local charUtil = lib.FunctionUtils.Character

local sharedModules = replicatedStorage.Modules.Shared

local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local inventorySharedUtil = require(sharedModules.Utils.InventoryUtilShared)

local directoryFolder = replicatedStorage.Directory

local module = setmetatable({}, { __index = replicableInstance }) --:: & replicableInstance.ClassType
module._Type = "Item"

export type ClassType =
	typeof(setmetatable(
		{} :: {
			Player: Player?,
			Inventory: { string },

			Heat: number,
			Health: number,
			Outfit: "Prisoner" | "Guard",
			Stamina: number,
			Fitness: number,
			Strength: number,
			Intellect: number,
			Money: number,
		},
		{ __index = module }
	))
	& replicableInstance.ClassType

function module.new(UID: string | number?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, replicableInstance, UID) :: ClassType

	return self
end
