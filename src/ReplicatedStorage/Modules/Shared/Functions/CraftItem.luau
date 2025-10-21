local serverStorage = game:GetService("ServerStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")

local inventoryUtilShared = require(replicatedStorage.Modules.Shared.Utils.InventoryUtilShared)

local instancesManager = require(replicatedStorage.Modules.Shared.Managers.InstancesManager)

local itemDir = require(replicatedStorage.Directory.Items)

local module = {}

local function lengthTable(t)
	print(t)
	local count = 0
	for i, k in t do
		print(i, k)
		count = count + 1
	end
	return count
end

function module.canCraftItem(player, itemId, craftNumber)
	local itemInfo = itemDir:getItemInfo(itemId)
	print(itemInfo)
	if not itemInfo then
		return nil
	end
	if not itemInfo.Crafts then
		return nil
	end
	local craft = itemInfo.Crafts[craftNumber]
	print(craft)
	if not craft then
		return nil
	end

	local playerInventory = inventoryUtilShared.getPlayerInventory(player)
	print(playerInventory)
	if not playerInventory then
		return nil
	end
	local necessaryItems = {}
	for i = 1, 3 do
		local item = craft["item" .. i]
		if item then
			table.insert(necessaryItems, item)
		end
	end

	local totalItemsNecessary = #necessaryItems
	local totalItemsInInventory = #playerInventory
	local diff = totalItemsInInventory - totalItemsNecessary
	print(diff)
	if diff < 0 then
		return false
	end
	if diff >= 6 then
		return false
	end

	local indexesUsed = {}
	for _, necessaryItem in necessaryItems do
		for index, itemUID in playerInventory do
			if indexesUsed[index] then
				continue
			end
			local item = instancesManager.getObj(itemUID)
			if item and item:IsA("Item") and item.Id == necessaryItem then
				indexesUsed[index] = true
				break
			end
		end
	end
	print(lengthTable(indexesUsed))
	print(totalItemsNecessary)
	if lengthTable(indexesUsed) ~= totalItemsNecessary then
		return false
	end

	return true, indexesUsed, playerInventory
end

return module
