local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

local itemsDirectory = require(replicatedStorage.Directory.Items)

local lib = require(replicatedStorage:WaitForChild("lib"))
local t = lib.FunctionUtils.t
local clientModules = replicatedStorage.Modules.Client
local sharedModules = replicatedStorage.Modules.Shared
local sharedClasses = sharedModules.Classes
local itemSharedClass = require(sharedClasses.ItemClasse)

local replicableInstance = require(sharedClasses.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local inventoryUtil = require(sharedModules.Utils.InventoryUtilShared)
local inventoryUtilClient = require(clientModules.Utils.InventoryUtilClient)

local itemHover = require(clientModules.Utils.ItemHover)

local localPlayer = game.Players.LocalPlayer

local module = setmetatable({}, { __index = itemSharedClass })
module.__index = module

export type ClassType = typeof(setmetatable(
	{} :: {
		Model: typeof(itemsDirectory.directoryFolder["00 _ Template"].Model),
		Display: Frame,

		animType: "KeyDown" | nil,
	},
	module
)) & itemSharedClass.ClassType

function module.new(UID: string)
	local self: ClassType = replicableInstance.newLinkedToAClass(module, itemSharedClass, UID) :: ClassType
	self._Type = "Item"

	return self
end

function module.Materialize(self: ClassType)
	-- ...
	return self
end

function module.CreateDisplay(self: ClassType)
	if self.Display then
		return self
	end
	self.Display = itemsDirectory:getItemDisplay(self.Id):Clone()
	self.Display.Name = self.UID
	local twI1 = TweenInfo.new(0.1, Enum.EasingStyle.Sine)
	local originalSize = self.Display.Size
	local futureSize = UDim2.fromScale(originalSize.X.Scale * 1.1, originalSize.Y.Scale * 1.1)
	local tw1 = tweenService:Create(self.Display, twI1, { Size = futureSize })
	local tw2 = tweenService:Create(self.Display, twI1, { Size = originalSize })
	self.Display.MouseEnter:Connect(function()
		tw1:Play()
	end)
	self.Display.MouseLeave:Connect(function()
		tw2:Play()
	end)
	self:AnimKeyDown()

	if self.Legal then
		self.Display.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		self.Display.Transparency = 1
	else
		self.Display.BackgroundColor3 = Color3.fromRGB(255, 0, 4)
		self.Display.Transparency = 0.85
	end

	return self
end

function module.AddToInventory(self: ClassType, inv: { any }?, slot: number?)
	local playerInventory = inv or inventoryUtil.getPlayerInventory(self.InstantiatedTo)
	if not playerInventory then
		return self
	end
	slot = slot or inventoryUtil.getItemSlot(playerInventory, self.UID) or inventoryUtil.getNextSlotForANewItem(playerInventory)
	inventoryUtilClient.putItemOnInventorySlot(self.UID, slot)

	return self
end

function module.AddToChest(self: ClassType, chestUID: string?, contentTabName: string?)
	self:CreateDisplay()
	self:AnimKeyDown()
	return self
end

function module.AnimKeyDown(self: ClassType)
	if self.animType == "KeyDown" then
		return
	end
	self.animType = "KeyDown"
	if not self.Display then
		self:CreateDisplay()
	end

	local conHoverStarted
	local conHoverEnded

	itemHover.addItem(self)

	local listening = false
	self.Display.MouseEnter:Connect(function()
		if listening then
			return
		end
		listening = true
		local conKey = userInputService.InputBegan:Connect(function(inp)
			if inp.KeyCode == Enum.KeyCode.E then
				print(self.InstantiatedTo)
				if type(self.InstantiatedTo) == "string" then
					
					self:tryToInstantiateTo(localPlayer)
				elseif t.Player(self.InstantiatedTo) then
					local chestOpen = localPlayer:GetAttribute("ChestOpen")
					if chestOpen then
						local chest = instancesManager.getObj(chestOpen)
						print(chest)
						print(chestOpen)
						self:TryToInstantiateTo(chestOpen, "DeskContents")
					end
				end
			end
		end)
		local conLeave
		conLeave = self.Display.MouseLeave:Connect(function()
			conKey:Disconnect()
			conLeave:Disconnect()
			listening = false
		end)
		self.Trove:Add(conKey)
		self.Trove:Add(conLeave)
	end)

	return self
end

function module.Drop(self: ClassType)
	self.Model:PivotTo(self.CFrame)
	self.Model.Parent = workspace

	return self
end

function module.InstantiateTo(self: ClassType, any: string | Player, chestStorage: string?)
	self.Remote:Fire(self.UID, "TryToInstantiateTo", { any, chestStorage })
	return self
end

function module.TryToInstantiateTo(self: ClassType, any: string | Player, chestStorage: string?)
	if self.InstantiatedTo == any then
		return self
	end

	local isPlayer = (typeof(any) == "Instance" and any:IsA("Player"))
	local isChest = (type(any) == "string" and any ~= "")
	local isGround = (type(any) == "string" and any == "")

	if not (isPlayer or isChest or isGround) then
		return self
	end

	if type(self.InstantiatedTo) == "string" and self.InstantiatedTo ~= "" then
		local chestNow = instancesManager.getObj(self.InstantiatedTo)
		if chestNow then
			chestNow:RemoveItem(self.UID)
		end
	end

	self:InstantiateTo(any, chestStorage)
	if isGround then
		self:Drop()
	elseif isChest then
		local chest = instancesManager.getObj(any :: string)
		if chest and chest._Type == "Chest" then
			self:AddToChest()
			chest:AddItem(self.UID, chestStorage)
		end
	elseif isPlayer then
		self:AddToInventory()
	end

	return self
end

function module.RemoveFromChest(self: ClassType)
	itemHover.removeItem(self.UID)
	return self
end

function module.Inventorize(self: ClassType)
	self:RemoveFromChest()

	return self
end

function module.EquipItem(self: ClassType)
	if self.equipped then
		return
	end
	if not (typeof(self.InstantiatedTo) == "Instance" and self.InstantiatedTo:IsA("Player")) then
		return
	end

	local char = self.InstantiatedTo.Character
	if char then
		local hrp = char.PrimaryPart
		if hrp then
			self.Model:PivotTo(hrp.CFrame * CFrame.new(0, 4, 0))
		end
	end

	return self
end

function module.UnequipItem(self: ClassType)
	if not self.equipped then
		return
	end

	return self
end

function module.ToggleEquip(self: ClassType) end

return module
