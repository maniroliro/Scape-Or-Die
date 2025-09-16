local replicatedStorage = game:GetService("ReplicatedStorage")

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local zonePlus = lib.ModuleUtils.ZonePlus

local sharedModules = replicatedStorage.Modules.Shared
local replicableInstance = require(sharedModules.Classes.ReplicableInstance)
local securityCameraSharedClass = require(sharedModules.Classes.SecurityCameraClass)

local directory = replicatedStorage.Directory
local securityCameraDirectory = require(directory.SecurityCameras)

local module = setmetatable({}, { __index = securityCameraSharedClass })
module.__index = module

export type ClassType = typeof(setmetatable(
	{} :: {
		--CameraArea: BasePart | Model, -- SERVER ONLY
		--CameraZone: { [any]: any }, -- SERVER ONLY
		Model: Model & BasePart,
		Support: typeof(module.Model.Support) & BasePart,
	},
	module
)) & securityCameraSharedClass.ClassType

function module.new(id: string?): ClassType
	local self: ClassType = replicableInstance.newLinkedToAClass(module, securityCameraSharedClass) :: ClassType
	self._Type = "Item"

	if id then
		self:AttachId(id)
	end
	return self
end

function module.Materialize(self: ClassType, CF: CFrame)
	local success = securityCameraSharedClass.Materialize(self, CF)
	if not success then
		return self
	end

	self.Model = target:IsA("PVInstance") and target
		or target:IsA("Attachment") and cameraModel
		or securityCameraDirectory:getItemModel(01)
	self.Support = self.Model:FindFirstChild("Support")
	print("a")
	for k, v in securityCameraDirectory:getItemModule(1) do
		self[k] = v
	end
	print("b")
	if target:IsA("Attachment") then
		self.Support.CFrame = target:FindFirstAncestorOfClass("BasePart").CFrame
			* target.CFrame
			* CFrame.new(self.Support.Size.X / 2, 0, 0)
	end

	return self
end

function module.AttachCameraArea(self: ClassType, part: BasePart)
	self.CameraArea = part
	self.CameraZone = zonePlus.new(self.CameraArea)
	self.PlayerEnteredCameraZone = self.CameraZone.playerEntered

	return self
end

function module.StartWatching(self: ClassType, plr)
	if not self.CameraArea then
		return
	end
end

function module.FinishWatching(self: ClassType) end

function module.AlertPolices(self: ClassType) end

function module.StartConnections(self: ClassType)
	if self.CameraZone then
		self:StartWatching()
		self.Trove:Connect(self.CameraZone.playerEntered, function(plr)
			print(plr)

			local data = dataStoreManager.get(plr)

			if data.hasAnIlegalItem then
				self:AlertPolices()
			end
		end)

		self.Trove:Connect(self.CameraZone.playerExited, function(plr)
			print(plr)

			self:FinishWatching()
		end)
	end

	return self
end

function module.start(self: ClassType)
	if self._started then
		return
	end
	self._started = true
	task.spawn(self.StartConnections, self)

	return self
end

function module.finish(self: ClassType)
	if not self._started then
		return
	end
	self._started = false
	self.Trove:Clean()

	return self
end

return module
