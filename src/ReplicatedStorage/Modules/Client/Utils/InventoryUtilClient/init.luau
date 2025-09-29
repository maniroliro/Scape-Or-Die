local ReplicatedStorage = game:GetService("ReplicatedStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")
local playersService = game:GetService("Players")
--local lib = require(replicatedStorage.lib)
local inventoryUtilShared = require(ReplicatedStorage.Modules.Shared.Utils.InventoryUtilShared)
local instancesManager = require(replicatedStorage.Modules.Shared.Managers.InstancesManager)

local localPlayer = playersService.LocalPlayer

local module = {}

function module.putItemOnInventorySlot(itemUID, slot)
	if not itemUID or not slot then
		return
	end
	local item = instancesManager.getObj(itemUID)
	if not item then
		return
	end
	item.Display.Parent = localPlayer.PlayerGui
		:WaitForChild("Inventory")
		:WaitForChild("Frame")
		:WaitForChild("Frame")
		:WaitForChild("PlaceHolder" .. slot)
end

function module.removeItemFromInventorySlot(itemUID)
	if not itemUID then
		return
	end
	local item = instancesManager.getObj(itemUID)
	if not item then
		return
	end
	-- Remove o Display do item do inventário
	if item.Display then
		item.Display.Parent = nil
	end
end

function module.toggleEquip(inv: { any }, pos1: number, pos2: number?)
	pos1, pos2 = inventoryUtilShared.normalizeToggleSlots(inv, pos1, pos2)
	if not pos1 or not pos2 then
		return false
	end
	local uid1, uid2 = inv[pos1], inv[pos2]
	local success = inventoryUtilShared.toggleEquip(inv, pos1, pos2)
	if not success then
		return false
	end
	module.putItemOnInventorySlot(uid1, pos2)
	module.putItemOnInventorySlot(uid2, pos1)
	return true, pos1, pos2
end

-- function module.putItemOnChestSlot(itemUID, chestUID, slot)
-- 	--TODO
-- end

return module
