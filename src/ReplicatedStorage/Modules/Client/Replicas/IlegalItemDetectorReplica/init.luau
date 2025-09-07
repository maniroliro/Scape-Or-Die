local replicatedStorage = game:GetService('ReplicatedStorage')
local tweenService = game:GetService('TweenService')
local Players = game:GetService('Players')

local localPlayer = Players.LocalPlayer

local ilegalItemsDetectorDirectory = require(replicatedStorage.Directory.IlegalItemDetector)

local lib = require(replicatedStorage:WaitForChild('lib'))
local charUtil = lib.FunctionUtils.Character
local t = lib.FunctionUtils.t
local replicableInstance = require(replicatedStorage.Modules.Shared.Classes.ReplicableInstance)

local inventorySharedUtil = require(replicatedStorage.Modules.Shared.Utils.InventoryUtilShared)

local module = setmetatable({}, replicableInstance)
module.__index = module

export type ClassType = typeof(setmetatable(
	{} :: {
		Model: typeof(ilegalItemsDetectorDirectory.directoryFolder['00 | Template'].Model),
		isActivated: boolean,
		CFrame: CFrame,
		DetectionArea: Part,
		AlertLights: {Part},

		AlertLevel: number, -- 0..3
		PlayerAlerting: boolean,
		AlertClientThread: thread?,

		LastBlinkedLight: number,
	},
	module
	)) & lib.ReplicableInstance & ilegalItemsDetectorDirectory.Type

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

local function clampLevel(n: number): number
	return math.clamp(n, 0, 3)
end

local function countSet(setTbl: {[number]: boolean}): number
	local n = 0
	for _ in setTbl do n += 1 end
	return n
end

function module.new(UID: string): ClassType
	local self: ClassType = setmetatable(replicableInstance.new(UID) :: lib.ReplicableInstance, module)
	self._Type = 'Item'
	self.AlertLights = {}
	self.AlertLevel = 0
	self.LastBlinkedLight = 1
	self.PlayerAlerting = nil
	return self
end

function module.AttachIlegalItemDetector(self: ClassType, itemId: number)
	local itemInfo = ilegalItemsDetectorDirectory:getItemInfo(itemId)
	if not itemInfo then return self end
	for k, v in itemInfo do
		self[k] = v
	end
	return self
end

function module.Materialize(self: ClassType, CF: CFrame)
	if not t.CFrame(CF) then return self end
	self.CFrame = CF

	self.Model = ilegalItemsDetectorDirectory:getItemModel(self.Id):Clone()
	self.Model:PivotTo(self.CFrame)
	self.Model.Name = self.UID
	self.Model.Parent = workspace

	self.DetectionArea = self.Model.DetectionArea
	self.DetectionArea.CFrame = CF

	self.AlertLights = {}
	for _, part in self.Model:GetDescendants() do
		if part.Name == 'AlertLight' and part:IsA('BasePart') then
			table.insert(self.AlertLights, part)
		end
	end
	return self
end

-- anima um passo de cor (pisca)
function module.ChangeLightsColor(self: ClassType, level: number?)
	task.spawn(function()
		self.LastBlinkedLight = (self.LastBlinkedLight == 2) and 1 or 2
		local lvl = level or self.AlertLevel
		local cfg = alertingSettings[lvl]
		if not cfg then return end

		local colorName = lvl == 0 and 'LightColor' or 'LightColor' .. self.LastBlinkedLight
		local color = cfg[colorName] or cfg.LightColor

		for _, part: Part in self.AlertLights do
			part.Color = color
			local pointLight = part:FindFirstChild('PointLight') :: PointLight?
			if pointLight then
				pointLight.Color = color
				if lvl == 0 then
					pointLight.Brightness = 0.5
					pointLight.Range = 6
				else
					pointLight.Brightness = 1.5
					pointLight.Range = 10
				end
			end
		end
	end)
	return self
end

-- aplica nível e controla o loop de pisca
function module.SetLevel(self: ClassType, newLevel: number)
	newLevel = clampLevel(newLevel)
	if newLevel == self.AlertLevel then
		return self
	end
	self.AlertLevel = newLevel
	self:ChangeLightsColor(newLevel)
	
	if newLevel == 0 then
		return self
	end

	task.spawn(function()
		local thisLevel = newLevel
		while task.wait(0.1) and self.AlertLevel == thisLevel do
			self:ChangeLightsColor(self.AlertLevel)
		end
	end)

	return self
end

-- entrada local (quando o próprio jogador toca e tem item ilegal)
function module.Alert(self: ClassType, level: number?)
	level = level or self.AlertLevel
	self:SetLevel(level)

	-- agenda a remoção local após o tempo do nível atual
	local duration = alertingSettings[level] and alertingSettings[level].TimeDuration or 0
	
	if self.AlertClientThread and self.AlertClientThread ~= coroutine.running() then
		task.cancel(self.AlertClientThread)
		self.AlertClientThread = nil
	end
	if duration > 0 then
		self.AlertClientThread = task.delay(duration, function()
			if self.PlayerAlerting then
				print(self.PlayerAlerting)
				self.PlayerAlerting = nil
				print(self.PlayerAlerting)
				local newLevel = self.AlertLevel - 1
				self:SetLevel(newLevel) -- se zerar, para de piscar
			end
		end)
	end

	return self
end

function module.PlayerTriggered(self: ClassType)
	if self.PlayerAlerting then return end
	self.PlayerAlerting = true
	

	self:SetLevel(clampLevel(self.AlertLevel + 1))
	self:Alert()
	
	return self
end


function module.Active(self: ClassType)
	if self.isActivated then return self end
	self.isActivated = true

	self.Trove:Add(self.DetectionArea.Touched:Connect(function(who: Instance)
		local plr = charUtil.getPlayerFromCharacter(who)
		if plr and plr == localPlayer then
			if inventorySharedUtil.isThereAnIlegalItemOnInventory(inventorySharedUtil.getPlayerInventory(plr)) then
				self:PlayerTriggered(plr) -- cliente anima e debouncia localmente
			end
		end
	end))

	return self
end

return module
