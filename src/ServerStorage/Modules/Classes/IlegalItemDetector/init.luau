local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local ilegalItemsDetectorDirectory = require(replicatedStorage.Directory.IlegalItemDetectors)
local lib = require(replicatedStorage.lib)
local charUtil = lib.FunctionUtils.Character
local t = lib.FunctionUtils.t

local sharedModules = replicatedStorage.Modules.Shared
local sharedClasses = sharedModules.Classes
local ilegalItemDetectorSharedClass = require(sharedClasses.IlegalItemDetectorClasse)

local replicableInstance = require(sharedClasses.ReplicableInstance)
local inventorySharedUtil = require(sharedModules.Utils.InventoryUtilShared)

local module = setmetatable({}, { __index = ilegalItemDetectorSharedClass })

export type ClassType = typeof(setmetatable({} :: {}, { __index = module })) & ilegalItemDetectorSharedClass.ClassType

function module.new(id: string | number?): ClassType
	local self: ClassType = replicableInstance.newLinkedToAClass(module, ilegalItemDetectorSharedClass) :: ClassType

	if id then
		self:AttachId(id)
	end
	return self
end

function module.Materialize(self: ClassType, CF: CFrame)
	local success = ilegalItemDetectorSharedClass.Materialize(self, CF)
	if not success then
		return self
	end

	self.DetectionArea = ilegalItemsDetectorDirectory:getItemModel(self.Id):Clone().DetectionArea
	self.DetectionArea.CFrame = self.CFrame
	self.DetectionArea.Parent = workspace

	self.Remote:Fire(self.UID, "Materialize", { self.CFrame })
	return self
end

function module.Alert(self: ClassType, level: number?)
	local success = ilegalItemDetectorSharedClass.Alert(self, level)
	if not success then
		return self
	end

	self.Remote:Fire(self.UID, "Alert", { self.AlertLevel })
	return self
end

-- jogador disparou (server valida globalmente e NOTIFICA TODOS)
function module.PlayerTriggered(self: ClassType, player: Player)
	local sucess = ilegalItemDetectorSharedClass.PlayerTriggered(self, player)
	if not sucess then
		return self
	end
	return self
end

function module.Active(self: ClassType, active: boolean?)
	local success = ilegalItemDetectorSharedClass.Active(self, active)
	if not success then
		return self
	end

	self.Remote:Fire(self.UID, "Active", {})
	return self
end

function module.ReplicateTo(self: ClassType, client: Player?)
	local newIlegalItemDetector = lib.Remotes.instanceCreated.IlegalItemDetector

	if client then
		newIlegalItemDetector:FireClient(client, self.UID)

		self.Remote:FireClient(client, self.UID, "AttachId", { self.Id })
		self.Remote:FireClient(client, self.UID, "Materialize", { self.CFrame })

		if self.isActivated then
			self.Remote:FireClient(client, self.UID, "Active", {})
		end
	else
		newIlegalItemDetector:Fire(self.UID)

		self.Remote:Fire(self.UID, "AttachId", { self.Id })
		self.Remote:Fire(self.UID, "Materialize", { self.CFrame })

		if self.isActivated then
			self.Remote:Fire(self.UID, "Active", {})
		end
	end

	return self
end

return module
