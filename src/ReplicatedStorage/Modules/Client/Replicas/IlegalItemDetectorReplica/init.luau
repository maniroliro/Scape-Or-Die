local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local ilegalItemsDetectorDirectory = require(replicatedStorage.Directory.IlegalItemDetectors)

local lib = require(replicatedStorage:WaitForChild("lib"))
local charUtil = lib.FunctionUtils.Character
local t = lib.FunctionUtils.t

local replicableInstance = require(replicatedStorage.Modules.Shared.Classes.ReplicableInstance)
local ilegalItemDetectorSharedClasse = require(replicatedStorage.Modules.Shared.Classes.IlegalItemDetectorClasse)

local inventorySharedUtil = require(replicatedStorage.Modules.Shared.Utils.InventoryUtilShared)

local module = setmetatable({}, ilegalItemDetectorSharedClasse)

export type ClassType = typeof(setmetatable(
	{} :: {
		Model: typeof(ilegalItemsDetectorDirectory.directoryFolder["00 | Template"].Model),
		AlertLights: { Part },

		AlertLevel: number, -- 0..3
		AlertClientThread: thread?,

		LastBlinkedLight: number,
	},
	{ index = module }
)) & ilegalItemDetectorSharedClasse.ClassType

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

function module.new(UID: string): ClassType
	local self: ClassType =
		replicableInstance.newLinkedToAClass(module, ilegalItemDetectorSharedClasse, UID) :: ClassType
	self.AlertLights = {}
	self.LastBlinkedLight = 1
	return self
end

function module.Materialize(self: ClassType, CF: CFrame)
	local canMaterialize = ilegalItemDetectorSharedClasse.Materialize(self, CF)
	if not canMaterialize then
		return self
	end

	-- Client-specific logic
	self.Model = ilegalItemsDetectorDirectory:getItemModel(self.Id):Clone()
	self.Model:PivotTo(self.CFrame)
	self.Model.Name = self.UID
	self.Model.Parent = workspace

	self.DetectionArea = self.Model.DetectionArea
	self.DetectionArea.CFrame = CF

	self.AlertLights = {}
	for _, part in self.Model:GetDescendants() do
		if part.Name == "AlertLight" and part:IsA("BasePart") then
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
		if not cfg then
			return
		end

		local colorName = lvl == 0 and "LightColor" or "LightColor" .. self.LastBlinkedLight
		local color = cfg[colorName] or cfg.LightColor

		for _, part: Part in self.AlertLights :: { Part } do
			part.Color = color
			local pointLight = part:FindFirstChild("PointLight") :: PointLight?
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
	-- Chama a classe compartilhada primeiro para validação
	local canSetLevel = ilegalItemDetectorSharedClasse.SetLevel(self, newLevel)
	if not canSetLevel then
		return self
	end

	-- Client-specific logic
	self:ChangeLightsColor(self.AlertLevel)

	if self.AlertLevel == 0 then
		return self
	end

	task.spawn(function()
		local thisLevel = self.AlertLevel
		while task.wait(0.1) and self.AlertLevel == thisLevel do
			self:ChangeLightsColor(self.AlertLevel)
		end
	end)

	return self
end

-- entrada local (quando o próprio jogador toca e tem item ilegal)
function module.Alert(self: ClassType, level: number?)
	local canAlert = ilegalItemDetectorSharedClasse.Alert(self, level)
	if not canAlert then
		return self
	end

	return self
end

function module.PlayerTriggered(self: ClassType)
	if self.PlayerAlerting then
		return
	end
	self.PlayerAlerting = true

	self:SetLevel(math.clamp(self.AlertLevel + 1, 0, 3))
	self:Alert()

	return self
end

function module.Active(self: ClassType, active: boolean?)
	local canActivate = ilegalItemDetectorSharedClasse.Active(self, active)
	if not canActivate then
		return self
	end

	return self
end

return module
