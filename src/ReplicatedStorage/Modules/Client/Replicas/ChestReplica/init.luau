local replicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local lib = require(replicatedStorage:WaitForChild("lib"))
local clientModules = replicatedStorage.Modules.Client
local sharedModules = replicatedStorage.Modules.Shared

local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local spring = lib.ModuleUtils.Spring
local charUtils = lib.FunctionUtils.Character

local chestDirectory = require(replicatedStorage.Directory.Chests)
local chestSharedClass = require(sharedModules.Classes.DerivedClasses.ChestClass)

local itemsReplica = require(clientModules.Replicas.ItemReplica)
local itemHover = require(clientModules.Utils.ItemHover)
local highlightSelectionUtil = require(clientModules.Utils.HighlightSelection)

local localplayer = PlayersService.LocalPlayer

local module = setmetatable({} :: {}, { __index = chestSharedClass })

export type ClassType =
	typeof(setmetatable(
		{} :: {
			Display: Frame, -- typeof(chestDirectory.directoryFolder["00 _ Template"].Display),
			DrawerSpring: typeof(spring.new()),
			DrawerPivotPosition: Vector3,
			ProximityPrompt: ProximityPrompt,
			ChestOpenByLocalPlayer: boolean,

			CloseDisplayButton: RBXScriptConnection?,
			MouseBehaviorConnection: RBXScriptConnection?,
		},
		{ __index = module }
	))
	& chestSharedClass.ClassType

function module.new(UID: string)
	local self: ClassType = replicableInstance.newLinkedToAClass(module, chestSharedClass, UID) :: ClassType
	self.ItemsInside = {
		DeskContents = {},
		HiddenContents = {},
	}
	self.ChestOpenByLocalPlayer = false

	return self
end

function module.OpenChest(self: ClassType)
	if self.ChestOpenByLocalPlayer then
		return self
	end

	local success = chestSharedClass.OpenChest(self, localplayer)
	if not success then
		return self
	end
	self.ChestOpenByLocalPlayer = true

	self.Display.Visible = true
	self.ProximityPrompt.Enabled = false

	print("unlocking mouse")
	userInputService.MouseBehavior = Enum.MouseBehavior.Default
	self.Display.Modal.Visible = true

	if self.MouseBehaviorConnection then
		self.MouseBehaviorConnection:Disconnect()
		self.MouseBehaviorConnection = nil
	end
	self.MouseBehaviorConnection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		userInputService.MouseBehavior = Enum.MouseBehavior.Default
	end)

	return self
end

function module.CloseChest(self: ClassType)
	if not self.ChestOpenByLocalPlayer then
		return self
	end

	local success = chestSharedClass.CloseChest(self, localplayer)
	if not success then
		return self
	end
	self.ChestOpenByLocalPlayer = false

	self.Display.Visible = false
	self.ProximityPrompt.Enabled = true

	print("locking mouse")
	userInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	self.Display.Modal.Visible = false

	if self.MouseBehaviorConnection then
		self.MouseBehaviorConnection:Disconnect()
		self.MouseBehaviorConnection = nil
	end
	self.MouseBehaviorConnection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		userInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end)

	return self
end

function module.Materialize(self: ClassType, CF: CFrame)
	local success = chestSharedClass.Materialize(self, CF)
	if not success then
		return self
	end
	self.ProximityPrompt = self.Model.Chest.ProximityPrompt

	-- self.Model:PivotTo(self.CFrame)
	-- self.Model.Parent = workspace
	self.DrawerPivotPosition = self.Model.Drawer:GetPivot().Position

	self.DrawerSpring = spring.new(0)
	self.DrawerSpring.Speed = 15

	self.ProximityPrompt.MaxActivationDistance = self.MaxDistanceToInteract
	self.ProximityPrompt.HoldDuration = self.OpenTime

	self.Trove:Add(self.ProximityPrompt.PromptButtonHoldBegan:Connect(function()
		self.Remote:Fire(self.UID, "playerBeganHoldingProximityPrompt", {})
	end))
	self.Trove:Add(self.ProximityPrompt.PromptButtonHoldEnded:Connect(function()
		self.Remote:Fire(self.UID, "playerEndedHoldingProximityPrompt", {})
	end))

	self.Trove:Add(self.ProximityPrompt.Triggered:Connect(function()
		self:OpenChest()
	end))

	local maxDistanceToInteract = self.MaxDistanceToInteract or 8

	self.Trove:Add(runService.RenderStepped:Connect(function()
		local hrp = charUtils.getAlivePlayerRootPart(localplayer)
		local sprPos = self.DrawerSpring.Position

		if not hrp then
			return
		end
		if (hrp.Position - self.Model.PrimaryPart.Position).Magnitude <= maxDistanceToInteract then
			self.DrawerSpring.Damping = 0.4
			self.DrawerSpring.Target = 40
			if self.DrawerSpring:IsAtRest() then
				self.DrawerSpring:Reset(40)
				return
			end
			self.Model.Drawer:PivotTo(CFrame.new(self.DrawerPivotPosition) * CFrame.Angles(0, 0, math.rad(-sprPos)))

			for _, a: Part in self.Model:GetChildren() do
				pcall(function()
					a.Color = Color3.fromRGB(50 + sprPos * 3, 50 + sprPos * 3, 50 + sprPos * 3)
				end)
			end
		else
			if self.ChestOpenByLocalPlayer then
				self:CloseChest()
				return
			end

			self.DrawerSpring.Damping = 0.75
			self.DrawerSpring.Target = 0
			if self.DrawerSpring:IsAtRest() then
				self.DrawerSpring:Reset(0)
				return
			end
			self.Model.Drawer:PivotTo(CFrame.new(self.DrawerPivotPosition) * CFrame.Angles(0, 0, math.rad(-sprPos)))

			for _, a: Part in self.Model:GetChildren() do
				pcall(function()
					a.Color = Color3.fromRGB(50 + sprPos * 3, 50 + sprPos * 3, 50 + sprPos * 3)
				end)
			end
		end
	end))

	highlightSelectionUtil.addSelection(self.Model)

	self.Display = chestDirectory:getItemDisplay(self.Id):Clone()
	self.Display.Name = self.UID
	self.Display.Visible = false
	self.Display.Parent = localplayer.PlayerGui.Chests

	self.CloseDisplayButton =
		self.Trove:Add((self.Display.Frame.Frame.XButton :: TextButton).Activated:Connect(function()
			print("Close button ")
			self:CloseChest()
		end))

	return self
end

function module.AddItem(self: ClassType, itemUID: string, contentTabName: string?, pos: number?)
	contentTabName = contentTabName or "DeskContents"
	local items = self.ItemsInside
	local contentTab = items[contentTabName]
	if not contentTab then
		return self
	end

	pos = pos or self:getNextFreeSlot(contentTabName)
	if not pos then
		return false
	end
	contentTab[pos] = itemUID

	local item = instancesManager.getObj(itemUID)
	if item then
		if not item.Display then
			item:CreateDisplay()
		end
		local container = self.Display.Frame.Frame.Frame:FindFirstChild(contentTabName).Items
		if container and item.Display then
			local placeholder = container:FindFirstChild("PlaceHolder" .. (pos :: number))
			if placeholder then
				item.Display.Parent = placeholder
			end
		end
	end

	return self
end

function module.RemoveItem(self: ClassType, itemUID: string, contentTabName: string?)
	if not itemUID then
		return self
	end
	local success = chestSharedClass.RemoveItem(self, itemUID, contentTabName)
	if not success then
		return self
	end

	local item = instancesManager.getObj(itemUID)
	if item and item.Display and item.Display.Parent then
		item.Display.Parent = nil
		itemHover.removeItem(itemUID)
	end

	return self
end

function module.UpdateItemsInside(self: ClassType, itemsUIDTab: { [string]: { string } })
	local itemsInside = self.ItemsInside
	for contentName, contentTab in itemsUIDTab do
		itemsInside[contentName] = {}

		-- Clear UI placeholders before repopulating
		local section = self.Display
			and self.Display:FindFirstChild("Frame")
			and self.Display.Frame:FindFirstChild("Frame")
			and self.Display.Frame:FindFirstChild(contentName)
		local container = section and section:FindFirstChild("Items")
		if container then
			for _, placeholder in container:GetChildren() do
				if typeof(placeholder) == "Instance" and placeholder.Name:match("^PlaceHolder") then
					for _, child in placeholder:GetChildren() do
						child.Parent = nil
					end
				end
			end
		end
		for i, uid in contentTab do
			local _item = (instancesManager.getObj(uid) or itemsReplica.new(uid)) :: itemsReplica.ClassType
			self:AddItem(uid, contentName, i)
		end
	end

	return self
end

return module
