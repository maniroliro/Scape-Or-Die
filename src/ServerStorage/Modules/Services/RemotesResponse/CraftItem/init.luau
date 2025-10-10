local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")

local inventoryUtilShared = require(replicatedStorage.Modules.Shared.Utils.InventoryUtilShared)
local instancesManager = require(replicatedStorage.Modules.Shared.Managers.InstancesManager)
local craftUtil = require(replicatedStorage.Modules.Shared.Functions.CraftItem)
local itemModule = require(serverStorage.Modules.Classes.Item)

return function(plr, itemToCraftId, craftIndex)
	local canCraft, itemsIndex, playerInventory = craftUtil.canCraftItem(plr, itemToCraftId, craftIndex)
	if not canCraft then
		return false
	end

	for index in itemsIndex do
		local itemUID = playerInventory[index]
		local item = instancesManager.getObj(itemUID)
		if item then
			item:Destroy()
		end
		inventoryUtilShared.removeItem(playerInventory, itemUID)
	end

	local newItem = itemModule.new()
	newItem:AttachId(itemToCraftId)
	newItem:Replicate(true)
	newItem:InstantiateTo(plr)

	--inventoryUtilShared.addItemToInventory(playerInventory, newItem.UID)

	return true
end
