local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local charUtil = lib.FunctionUtils.Character
local t = lib.FunctionUtils.t
local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)

local directoryFolder = replicatedStorage.Directory

local inventorySharedUtil = require(sharedModules.Utils.InventoryUtilShared)
local scannerDirectory = require(directoryFolder.Scanners)

local module = setmetatable({}, { __index = replicableInstance })
module._Type = replicableInstance.extendType("Scanner")

local function clampLevel(n: number): number
	return math.clamp(n, 0, 3)
end

local alertingSettings = {
	[0] = {
		LightColor = Color3.fromRGB(85, 255, 255),
	},
	[1] = {
		TimeDuration = 6,
		LightColor1 = Color3.new(1, 0, 0.0156863),
		LightColor2 = Color3.new(0.388235, 0, 0.00784314),
	},
	[2] = {
		TimeDuration = 10,
		LightColor1 = Color3.new(1, 0, 0.0156863),
		LightColor2 = Color3.new(0.388235, 0, 0.00784314),
	},
	[3] = {
		TimeDuration = 15,
		LightColor1 = Color3.new(1, 1, 1),
		LightColor2 = Color3.new(0, 0, 0),
	},
}

export type ClassType =
	typeof(setmetatable(
		{} :: {
			isActivated: boolean,
			DetectionArea: Part,
			CFrame: CFrame,
			Model: Model, -- typeof(replicatedStorage.Assets.IlegalItemsDetectors["00 _ Template"].Model),
			AlertLevel: number,
			PlayersAlerting: { Player },
			AlertClientThread: thread?,
			DetectionAreaEvent: RBXScriptConnection?,
		},
		{ __index = module }
	))
	& replicableInstance.ClassType
	& scannerDirectory.Type

function module.new(UID: string | number?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, replicableInstance, UID) :: ClassType
	self.AlertLevel = 0
	self.PlayersAlerting = {}
	self.isActivated = false

	return self
end

function module.Materialize(self: ClassType, CF: CFrame)
	local success = replicableInstance.Materialize(self, CF)
	if not success then
		return false
	end

	return self
end

function module.SetLevel(self: ClassType, newLevel: number)
	if not t.number(newLevel) then
		return false
	end
	newLevel = clampLevel(newLevel)
	if newLevel == self.AlertLevel then
		return false
	end
	self.AlertLevel = newLevel

	return self
end

function module.Alert(self: ClassType, level: number?)
	level = level or self.AlertLevel
	self:SetLevel(level)

	if self.AlertClientThread and self.AlertClientThread ~= coroutine.running() then
		task.cancel(self.AlertClientThread)
		self.AlertClientThread = nil
	end

	local duration = alertingSettings[self.AlertLevel] and alertingSettings[self.AlertLevel].TimeDuration or 0
	if duration > 0 then
		self.AlertClientThread = task.delay(duration, function()
			table.clear(self.PlayersAlerting)
			self.PlayersAlerting = {}
			self:Alert(#self.PlayersAlerting)
			print("alerting players")
			self.AlertClientThread = nil
		end)
	end

	return self
end

function module.PlayerTriggered(self: ClassType, player: Player)
	if not table.find(self.PlayersAlerting, player) then
		table.insert(self.PlayersAlerting, player)
	end

	self:Alert(#self.PlayersAlerting)

	return self
end

function module.Active(self: ClassType, active: boolean?)
	active = active == nil and true or active
	if self.isActivated == active then
		return false
	end
	self.isActivated = active :: boolean

	if self.isActivated then
		self.DetectionAreaEvent = self.DetectionArea.Touched:Connect(function(who: Instance)
			local plr = charUtil.getPlayerFromCharacter(who)
			print(plr)
			if plr then
				local inv = inventorySharedUtil.getPlayerInventory(plr)
				print(inv)
				if inventorySharedUtil.isThereAnIlegalItemOnInventory(inv) then
					print("player triggered")
					self:PlayerTriggered(plr) -- cliente anima e debouncia localmente
				end
			end
		end)
		self.Trove:Add(self.DetectionAreaEvent)
	else
		if self.DetectionAreaEvent then
			self.DetectionAreaEvent:Disconnect()
			self.DetectionAreaEvent = nil
		end
	end

	return self
end

return module
