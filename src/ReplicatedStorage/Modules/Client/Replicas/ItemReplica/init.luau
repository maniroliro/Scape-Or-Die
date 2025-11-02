local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

local itemsDirectory = require(replicatedStorage.Directory.Items)
local itemsFunctionDirectory = require(replicatedStorage.Directory.ItemsFunction)

local lib = require(replicatedStorage:WaitForChild("lib"))
local t = lib.FunctionUtils.t
local charUtil = lib.FunctionUtils.Character
local clientModules = replicatedStorage.Modules.Client
local sharedModules = replicatedStorage.Modules.Shared
local sharedClasses = sharedModules.Classes
local itemSharedClass = require(sharedClasses.ItemClass)

local replicableInstanceClass = require(sharedClasses.BaseClasses.ReplicableInstanceClass)

local inventoryUtil = require(sharedModules.Utils.InventoryUtilShared)
local inventoryUtilClient = require(clientModules.Utils.InventoryUtilClient)
local viewModelManager = require(clientModules.Managers.ViewModelManager)

local assetsFolder = replicatedStorage:WaitForChild("Assets")
local itemInfoOverlay = assetsFolder:WaitForChild("Displays"):WaitForChild("ItemInfoOverlay")

local frameHover = require(clientModules.Utils.FrameHover)
local itemHover = frameHover.newHover(itemInfoOverlay, function(self, item)
	if not item then
		return
	end
	self.Display.UIStroke.Color = item.Legal and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 0, 4)
	self.Display.Info.ItemName.Text = item.Id .. " _ " .. item.Name -- or "Unknown Item"

	local infoinfo = self.Display.Info.Info
	infoinfo.Speed.Text = "Speed: " .. item.AttackInfos.Speed.Name
	infoinfo.Damage.Text = "Damage: " .. item.AttackInfos.Damage.Name
	infoinfo.Range.Text = "Range: " .. item.AttackInfos.Range.Name
end)

local localPlayer = game.Players.LocalPlayer

-- local module = setmetatable({}, { __index = itemSharedClass })
local module = {}
local moduleClass = itemSharedClass:newFromThis(module)

export type ClassType = itemSharedClass.ClassType & typeof(moduleClass) & {
	Display: Frame,

	animType: "KeyDown" | nil,
	useItemConnection: RBXScriptConnection?,
}

function module.new(UID: string?): ClassType
	-- local self = replicableInstanceClass.newLinkedToAClass(module, itemSharedClass.new(UID)) :: ClassType
	local self = itemSharedClass.new(UID):AddInheritance(moduleClass)
	return self
end

function module.Materialize(self: ClassType, info: replicableInstanceClass.MaterializeInfo)
	print(self.Model)
	if self.Model then
		return self
	end
	local success = itemSharedClass.Materialize(self, info)
	if not success then
		return self
	end
	print(self.Model)

	return self
end

function module.CreateDisplay(self: ClassType)
	if self.Display then
		return self
	end

	self.Display = itemsDirectory:getItemDisplay(self.Id):Clone()

	if not self.Display then
		return self
	end

	self.Display.Name = self.UID
	local twI1 = TweenInfo.new(0.1, Enum.EasingStyle.Sine)
	local originalSize = self.Display.Size
	local futureSize = UDim2.fromScale(originalSize.X.Scale * 1.1, originalSize.Y.Scale * 1.1)
	local tw1 = tweenService:Create(self.Display.ImageLabel, twI1, { Size = futureSize })
	local tw2 = tweenService:Create(self.Display.ImageLabel, twI1, { Size = originalSize })
	self.Display.MouseEnter:Connect(function()
		tw1:Play()
	end)
	self.Display.MouseLeave:Connect(function()
		tw2:Play()
	end)

	if self.Legal then
		self.Display.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		self.Display.Transparency = 1
	else
		self.Display.BackgroundColor3 = Color3.fromRGB(255, 0, 4)
		self.Display.Transparency = 0.85
	end

	return self
end

-- function module.ChangeDisplayType(self: ClassType, newDisplay: "Trace" | "Flat")
-- 	if self.Display then
-- 		self.Display:Destroy()
-- 		self.Display = nil
-- 	end
-- 	self.Display = newDisplay

-- 	return self
-- end

function module.AddToInventory(self: ClassType, inv: { any }?, slot: number?)
	local success = itemSharedClass.AddToInventory(self, inv, slot)
	if not success then
		return self
	end

	if not self.Display then
		self:CreateDisplay()
	end

	-- Lógica específica do cliente
	if self.InstantiatedTo ~= localPlayer then
		return self
	end
	local playerInventory = inv or inventoryUtil.getPlayerInventory(self.InstantiatedTo)
	if not playerInventory then
		return self
	end
	slot = slot
		or inventoryUtil.getItemSlot(playerInventory, self.UID)
		or inventoryUtil.getNextSlotForANewItem(playerInventory)
	inventoryUtilClient.putItemOnInventorySlot(self.UID, slot)

	self:AnimKeyDown()
	itemHover:forceHide(self)

	return self
end

function module.AddToChest(self: ClassType, chestUID: string?, contentTabName: string?)
	local sucess = itemSharedClass.AddToChest(self, chestUID, contentTabName)
	if not sucess then
		return self
	end
	self:CreateDisplay()
	self:AnimKeyDown()
	return self
end

function module.AnimItemInfo(self: ClassType)
	if not self.Display then
		self:CreateDisplay()
	end

	itemHover:addItem(self)

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

	self:AnimItemInfo()

	local listening = false
	self.Display.MouseEnter:Connect(function()
		print(listening)
		print(self.Display)
		if listening then
			return
		end
		listening = true
		local conKey = userInputService.InputBegan:Connect(function(inp)
			print(inp)
			if inp.KeyCode == Enum.KeyCode.E then
				if type(self.InstantiatedTo) == "string" then
					self:TryToInstantiateTo(localPlayer)
				elseif t.Player(self.InstantiatedTo) then
					local chestOpen = localPlayer:GetAttribute("ChestOpen")
					if chestOpen then
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
			--self.animType = nil
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

function module.InstantiateTo(self: ClassType, newInstantiate: string | Player, chestStorage)
	local success = itemSharedClass.InstantiateTo(self, newInstantiate, chestStorage)
	if not success then
		return self
	end

	self:AnimKeyDown()
	return self
end

function module.TryToInstantiateTo(self: ClassType, any: string | Player, chestStorage: string?)
	local success = itemSharedClass.TryToInstantiateTo(self, any, chestStorage)
	if not success then
		return self
	end

	self.Remote:Fire(self.UID, "TryToInstantiateTo", { any, chestStorage })
	return self
end

function module.RemoveFromChest(self: ClassType, chestUID: string?)
	local success = itemSharedClass.RemoveFromChest(self, chestUID)
	if not success then
		return self
	end

	-- Lógica específica do cliente
	--itemHover.removeItem(self.UID)
	return self
end

function module.RemoveFromInventory(self: ClassType, inv: { any })
	local success = itemSharedClass.RemoveFromInventory(self, inv)
	if not success then
		return self
	end

	inventoryUtilClient.removeItemFromInventorySlot(self.UID)
	return self
end

function module.AnimateUseItem(self: ClassType)
	return self
end

function module.UseItem(self: ClassType, funcN: number)
	if self.InstantiatedTo == localPlayer then
		self:AnimateUseItem()
		--local success = itemSharedClass.UseItem(self, funcN)
		--print("client, ", success)
	else
		print(self.InstantiatedTo, " is trying to use item ", self.UID)
	end

	return self
end

function module.TryToUseItem(self: ClassType, funcN: number)
	local success = itemSharedClass.CanUseItem(self, funcN)
	if not success then
		return self
	end

	self:AnimateUseItem()

	self.Remote:Fire(self.UID, "TryToUseItem", { funcN })
	return self
end

function module.EquipItem(self: ClassType)
	local success = itemSharedClass.EquipItem(self)
	if not success then
		return self
	end

	if self.InstantiatedTo == localPlayer then
		viewModelManager.AttachItem(self.Model)
		local itemsFunctionTable = self.ItemFunction
		if itemsFunctionTable and #itemsFunctionTable >= 0 then
			local func1 = itemsFunctionDirectory:getItemInfo(itemsFunctionTable[1])
			local func2 = itemsFunctionDirectory:getItemInfo(itemsFunctionTable[2])
			if func1 or func2 then
				self.useItemConnection = self.Trove:Add(userInputService.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then
						if func1 then
							self:TryToUseItem(1)
						end
					elseif inp.UserInputType == Enum.UserInputType.MouseButton2 then
						if func2 then
							self:TryToUseItem(2)
						end
					end
				end))
			end
		end

		--self.Remote:Fire(self.UID, "TryToEquip", {})
	else
		print(self.InstantiatedTo, " is trying to equip item ", self.UID)
	end

	return self
end

function module.UnequipItem(self: ClassType)
	print("Unequipping item")
	local success = itemSharedClass.UnequipItem(self)
	if not success then
		return self
	end
	if self.InstantiatedTo == localPlayer then
		viewModelManager.UnattachItem(self.Model)
		if self.useItemConnection then
			self.useItemConnection:Disconnect()
			self.useItemConnection = nil
		end
		self.Model.Parent = nil

		--self.Remote:Fire(self.UID, "TryToUnequip", { pos })
	else
		print(self.InstantiatedTo, " is trying to unequip item ", self.UID)
	end

	return self
end

function module.ToggleEquip(self: ClassType)
	local success = itemSharedClass.ToggleEquip(self)
	if not success then
		return self
	end

	return self
end

return moduleClass
