local replicatedStorage = game:GetService("ReplicatedStorage")
local collectionService = game:GetService("CollectionService")

local sharedModules = replicatedStorage.Modules.Shared
local replicableInstance = require(sharedModules.Classes.ReplicableInstance)

local directoryFolder = replicatedStorage.Directory

local securityCamerasDirectory = require(directoryFolder.SecurityCameras)

local module = setmetatable({}, { __index = replicableInstance }) --:: & replicableInstance.ClassType
module._Type = "SecurityCamera"

export type ClassType =
	typeof(setmetatable(
		{} :: {
			isActivated: boolean,

			AttachedToWall: BasePart,
			CFrame: CFrame,
			Model: Model,
			CameraModel: Model,
		},
		{ __index = module }
	))
	& replicableInstance.ClassType
	& securityCamerasDirectory.Type

function module.new(UID: string | number?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, replicableInstance, UID) :: ClassType

	return self
end

function module.Materialize(self: ClassType, wallUID: string)
	local success = replicableInstance.Materialize(self, wallUID)
	print(success)
	if not success then
		return false
	end
	print(wallUID)
	local wall = wallUID and workspace:FindFirstAncestor(wallUID)
	print(wall)
	if not wall then
		for _, instance in collectionService:GetTagged("Wall") do
			if instance:GetAttribute("UID") == wallUID then
				wall = instance
				break
			end
		end
	end

	print(wall)
	if not wall or not wall.Parent or not wall:HasTag("Wall") then
		return false
	end
	print("s")
	self.CameraModel = self.Model:FindFirstChild("FunctionalCamera") :: Model
	self.AttachedToWall = wall
	self.CFrame = wall.CFrame * CFrame.new(0, 3, -wall.Size.Z / 2 + self.Model.PrimaryPart.Size.Z / 4)
	return self
end

-- function module.StartWatching(self: ClassType, plr)
-- 	if not self.CameraArea then
-- 		return
-- 	end
-- end

function module.FinishWatching(self: ClassType) end

function module.AlertPolices(self: ClassType) end

function module.Active(self: ClassType, active: boolean?)
	active = active == nil and true or active
	if self.isActivated == active then
		return false
	end
	self.isActivated = active :: boolean
	return self
end

return module
