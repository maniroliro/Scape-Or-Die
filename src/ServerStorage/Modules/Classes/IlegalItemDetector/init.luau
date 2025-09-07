local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local ilegalItemsDetectorDirectory = require(replicatedStorage.Directory.IlegalItemDetector)
local lib = require(replicatedStorage.lib)
local charUtil = lib.FunctionUtils.Character
local t = lib.FunctionUtils.t
local replicableInstance = require(replicatedStorage.Modules.Shared.Classes.ReplicableInstance)
--TODO
local zonePlus = lib.ModuleUtils.ZonePlus

local inventorySharedUtil = require(replicatedStorage.Modules.Shared.Utils.InventoryUtilShared)

local module = setmetatable({}, replicableInstance)
module.__index = module

export type ClassType = typeof(setmetatable(
	{} :: {
		isActivated: boolean,
		CFrame: CFrame,
		DetectionArea: Part,

		AlertLevel: number, -- 0..3
		PlayersAlerting: { Player | nil }, -- set global por userId
		AlertClientThread: thread?,
	},
	module
)) & lib.ReplicableInstance & ilegalItemsDetectorDirectory.Type

local alertingConfigurations = {
	[1] = { TimeDuration = 6 },
	[2] = { TimeDuration = 10 },
	[3] = { TimeDuration = 15 },
}

local function clampLevel(n: number): number
	return math.clamp(n, 0, 3)
end

function module.new(id: string | number?): ClassType
	local self: ClassType = setmetatable(replicableInstance.new() :: lib.ReplicableInstance, module)
	self._Type = "IlegalItemDetector"
	self.AlertLevel = 0
	self.PlayersAlerting = {}
	if id then
		self:AttachIlegalItemDetector(id)
	end
	return self
end

function module.Materialize(self: ClassType, CF: CFrame)
	if not t.CFrame(CF) then
		return self
	end
	self.CFrame = lib.Utils.GetLegalCFrame(CF)

	self.DetectionArea = ilegalItemsDetectorDirectory:getItemModel(self.Id):Clone().DetectionArea
	self.DetectionArea.CFrame = self.CFrame
	self.DetectionArea.Parent = workspace

	self.Remote:Fire(self.UID, "Materialize", { self.CFrame })
	return self
end

function module.AttachIlegalItemDetector(self: ClassType, id: string | number?)
	if not (t.number(id) or t.string(id)) then
		return self
	end
	local info = ilegalItemsDetectorDirectory:getItemInfo(id)
	if not info then
		return self
	end
	for k, v in info do
		self[k] = v
	end
	self.Remote:Fire(self.UID, "AttachIlegalItemDetector", { self.Id })
	return self
end

function module.Alert(self: ClassType, level: number?)
	if self.AlertLevel == level then
		return self
	end
	self.AlertLevel = level and clampLevel(level) or self.AlertLevel
	if self.AlertClientThread and self.AlertClientThread ~= coroutine.running() then
		task.cancel(self.AlertClientThread)
		self.AlertClientThread = nil
	end

	local duration = alertingConfigurations[self.AlertLevel] and alertingConfigurations[self.AlertLevel].TimeDuration
		or 0
	if duration > 0 then
		self.AlertClientThread = task.delay(duration, function()
			if self.PlayersAlerting then
				table.clear(self.PlayersAlerting)
				self.PlayersAlerting = {}
				self.AlertLevel = clampLevel(#self.PlayersAlerting)
				self:Alert()
				print("alerting players")
				self.Remote:Fire(self.UID, "Alert", { self.AlertLevel })
			end
			self.AlertClientThread = nil
		end)
	end

	self.Remote:Fire(self.UID, "Alert", { self.AlertLevel })
	return self
end

-- jogador disparou (server valida globalmente e NOTIFICA TODOS)
function module.OnTriggerByPlayer(self: ClassType, player: Player)
	if not table.find(self.PlayersAlerting, player) then
		table.insert(self.PlayersAlerting, player)
	end

	self.AlertLevel = #self.PlayersAlerting
	self:Alert()

	return self
end

function module.Active(self: ClassType)
	if self.isActivated then
		return self
	end
	self.isActivated = true
	self.Trove:Add(self.DetectionArea.Touched:Connect(function(who: Instance)
		local plr = charUtil.getPlayerFromCharacter(who)
		if plr then
			local inv = inventorySharedUtil.getPlayerInventory(plr)
			if inventorySharedUtil.isThereAnIlegalItemOnInventory(inv) then
				self:OnTriggerByPlayer(plr) -- server valida e AVISA TODO MUNDO
			end
		end
	end))

	self.Remote:Fire(self.UID, "Active", {})
	return self
end

function module.ReplicateTo(self: ClassType, client: Player?)
	local newIlegalItemDetector = lib.Remotes.instanceCreated.IlegalItemDetector

	if client then
		newIlegalItemDetector:FireClient(client, self.UID)

		self.Remote:FireClient(client, self.UID, "AttachIlegalItemDetector", { self.Id })
		self.Remote:FireClient(client, self.UID, "Materialize", { self.CFrame })

		if self.isActivated then
			self.Remote:FireClient(client, self.UID, "Active", {})
		end
	else
		newIlegalItemDetector:Fire(self.UID)

		self.Remote:Fire(self.UID, "AttachIlegalItemDetector", { self.Id })
		self.Remote:Fire(self.UID, "Materialize", { self.CFrame })

		if self.isActivated then
			self.Remote:Fire(self.UID, "Active", {})
		end
	end

	return self
end

return module
