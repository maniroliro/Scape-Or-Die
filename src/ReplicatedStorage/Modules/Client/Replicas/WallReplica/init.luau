local replicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local lib = require(replicatedStorage:WaitForChild("lib"))
local spring = lib.ModuleUtils.Spring
local charUtils = lib.FunctionUtils.Character

local clientModules = replicatedStorage.Modules.Client
local sharedModules = replicatedStorage.Modules.Shared

local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local highlightSelectionUtil = require(clientModules.Utils.HighlightSelection)

local wallSharedClass = require(sharedModules.Classes.DerivedClasses.WallClass)
local wallDirectory = require(replicatedStorage.Directory.Walls)

local localplayer = PlayersService.LocalPlayer

local module = setmetatable({}, { __index = wallSharedClass })

export type ClassType =
	typeof(setmetatable(
		{} :: {
			BillboardGuiInfo: BillboardGui?,
		},
		{ __index = module }
	))
	& wallSharedClass.ClassType

function module.new(UID: string)
	local self: ClassType = replicableInstance.newLinkedToAClass(module, wallSharedClass, UID) :: ClassType

	return self
end

function module.Materialize(self: ClassType, CF: CFrame)
	local success = wallSharedClass.Materialize(self, CF)
	if not success then
		return self
	end

	if self.Model then
		local billboardGui = wallDirectory:FindFirstChildOfClass(self.Id, "BillboardGui")
		self.BillboardGuiInfo = billboardGui:Clone()
		self.BillboardGuiInfo.Parent = self.Model
		self.BillboardGuiInfo.MaxDistance = 8
		self.BillboardGuiInfo.Frame.TextLabel.Text = "Health: " .. self.Health .. "/" .. self.MaxHealth
		self.Model.Parent = workspace

		self.HealthChanged:Connect(function(newHealth: number)
			if self.BillboardGuiInfo and self.BillboardGuiInfo.Frame and self.BillboardGuiInfo.Frame.TextLabel then
				self.BillboardGuiInfo.Frame.TextLabel.Text = "Health: " .. newHealth .. "/" .. self.MaxHealth
			end
		end)

		highlightSelectionUtil.addSelection(self.Model)
	end

	return self
end

function module.DestroyModel(self: ClassType)
	local success = wallSharedClass.DestroyModel(self)
	if not success then
		return self
	end

	if self.Model then
		print("bill", self.BillboardGuiInfo)
		if self.BillboardGuiInfo then
			self.BillboardGuiInfo.Enabled = false
		end
	end
	return self
end

return module
