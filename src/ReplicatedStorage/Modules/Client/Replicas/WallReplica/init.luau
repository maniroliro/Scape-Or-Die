local replicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local lib = require(replicatedStorage:WaitForChild("lib"))
local clientModules = replicatedStorage.Modules.Client
local sharedModules = replicatedStorage.Modules.Shared

local replicableInstance = require(sharedModules.Classes.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local spring = lib.ModuleUtils.Spring
local charUtils = lib.FunctionUtils.Character

local wallSharedClass = require(sharedModules.Classes.WallClass)

local localplayer = PlayersService.LocalPlayer

local module = setmetatable({}, { __index = wallSharedClass })

export type ClassType = typeof(setmetatable({} :: {}, { __index = module })) & wallSharedClass.ClassType

function module.new(UID: string)
	local self: ClassType = replicableInstance.newLinkedToAClass(module, wallSharedClass, UID) :: ClassType

	return self
end

function module.Materialize(self: ClassType, CF: CFrame) end

return module
