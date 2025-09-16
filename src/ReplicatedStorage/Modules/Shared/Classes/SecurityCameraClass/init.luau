local replicatedStorage = game:GetService("ReplicatedStorage")

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local charUtil = lib.FunctionUtils.Character

local sharedModules = replicatedStorage.Modules.Shared
local replicableInstance = require(sharedModules.Classes.ReplicableInstance)
local inventorySharedUtil = require(sharedModules.Utils.InventoryUtilShared)

local directoryFolder = replicatedStorage.Directory

local securityCamerasDirectory = require(directoryFolder.SecurityCameras)

local module = setmetatable({}, { __index = replicableInstance }) --:: & replicableInstance.ClassType
module._Type = "SecurityCamera"

export type ClassType = typeof(setmetatable(
	{} :: {
		isActivated: boolean,
		CameraArea: BasePart | Model,
		CameraZone: { [any]: any },
		Support: typeof(module.Model.Support) & BasePart,
		EnteredAreaEvent: lib.Signal<nil, Player>?,
		ExitedAreaEvent: lib.Signal<nil, Player>?,
	},
	{ __index = module }
)) & replicableInstance.ClassType & securityCamerasDirectory.Type

function module.new(UID: string | number?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, replicableInstance, UID) :: ClassType
	self.items = {}

	return self
end

function module.Materialize(self: ClassType, CF: CFrame)
	local success = replicableInstance.Materialize(self, CF)
	if not success then
		return self
	end

	self.Model = securityCamerasDirectory:getItemModel(01)
	self.Support = self.Model:FindFirstChild("Support") :: BasePart
	self.Support.CFrame = CF

	for k, v in securityCamerasDirectory:getItemModule(1) do
		self[k] = v
	end

	self.isActivated = false
	return self
end

function module.StartWatching(self: ClassType, plr)
	if not self.CameraArea then
		return
	end
end

function module.FinishWatching(self: ClassType) end

function module.AlertPolices(self: ClassType) end

function module.Active(self: ClassType, active: boolean?)
	active = active == nil and true or active
	if self.isActivated == active then
		return false
	end
	self.isActivated = active :: boolean

	if self.isActivated then
		if self.CameraZone then
			self:StartWatching()
			self.EnteredAreaEvent = self.Trove:Connect(self.CameraZone.playerEntered, function(plr)
				print(plr)
				local inv = inventorySharedUtil.getPlayerInventory(plr)
				print(inv)
				if inventorySharedUtil.isThereAnIlegalItemOnInventory(inv) then
					print("player triggered")
					self:AlertPolices(plr)
				end
			end)

			self.ExitedAreaEvent = self.Trove:Connect(self.CameraZone.playerExited, function(plr)
				print(plr)

				self:FinishWatching()
			end)
		end
	else
		if self.EnteredAreaEvent then
			self.EnteredAreaEvent:Disconnect()
			self.EnteredAreaEvent = nil
		end
		if self.ExitedAreaEvent then
			self.ExitedAreaEvent:Disconnect()
			self.ExitedAreaEvent = nil
		end
	end

	return self
end

return module
