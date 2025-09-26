local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local starterGui = game:GetService("StarterGui")
local localPlayer = game.Players.LocalPlayer

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage:WaitForChild("lib"))
local inventoryUtilShared = require(sharedModules.Utils.InventoryUtilShared)
local inventoryUtilClient = require(replicatedStorage.Modules.Client.Utils.InventoryUtilClient)
local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local instanceManager = require(sharedModules.Managers.InstancesManager)

local playerData = require(replicatedStorage.Modules.Client.PlayerData)

local module = {}
module.inventoryItems = {}
module.equippeditem = nil

local acceptableInputs = {
	One = 1,
	Two = 2,
	Three = 3,
	Four = 4,
	Five = 5,
	Six = 6,
}

function module.Init()
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	-- starterGui:SetCore("AvatarContextMenuTheme", {
	-- 	BackgroundImage = "",
	-- 	BackgroundTransparency = 0.5,
	-- 	BackgroundColor = Color3.fromRGB(111, 145, 242),
	-- 	NameTagColor = Color3.fromRGB(0, 0, 200),
	-- 	NameUnderlineColor = Color3.fromRGB(213, 233, 255),
	-- 	ButtonFrameColor = Color3.fromRGB(15, 24, 65),
	-- 	ButtonFrameTransparency = 0.2,
	-- 	ButtonUnderlineColor = Color3.fromRGB(213, 233, 255),
	-- 	Font = Enum.Font.SciFi,
	-- })
end

function module.Start()
	print("InventoryController Started")
	userInputService.InputBegan:Connect(function(inp)
		local acceptableInp = acceptableInputs[inp.KeyCode.Name]
		if acceptableInp then
			local inventory = inventoryUtilShared.getPlayerInventory(localPlayer)
			if not inventory then
				return
			end
			inventoryUtilClient.toggleEquip(inventory, acceptableInp)
			--end
		end
	end)
	-- playerData.NewDataReceived:Connect(function(data)
	-- 	print('analize')
	-- 	local oldData = playerData.Data
	-- 	for i, currentItemUID in data.inventory do
	-- 		local previousItemUID = oldData.inventory[i]
	-- 		if previousItemUID == currentItemUID then continue end
	-- 		local item = instancesManager.getObj(currentItemUID)
	-- 		local pos = table.find(oldData, currentItemUID)
	-- 		if pos then
	-- 			inventoryUtilShared.toggleEquip(player, pos, i)
	-- 		else

	-- 		end
	-- 	end
	-- end)
end

return module
