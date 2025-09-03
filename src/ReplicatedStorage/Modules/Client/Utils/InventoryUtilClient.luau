local replicatedStorage = game:GetService("ReplicatedStorage")
local playersService = game:GetService('Players')
local lib = require(replicatedStorage.lib)
local instancesManager = require(replicatedStorage.Modules.Shared.Managers.InstancesManager)

local localPlayer = playersService.LocalPlayer

local module = {}

function module.putItemOnInventorySlot(itemUID, slot)
	if not itemUID or not slot then return end
	local item = instancesManager.getObj(itemUID)
	if not item then return end
	item:Inventorize()
	item.Display.Parent = localPlayer.PlayerGui:WaitForChild('Inventory'):WaitForChild('Frame'):WaitForChild('Frame'):WaitForChild('PlaceHolder'..slot)
end

function module.putItemOnChestSlot(itemUID, chestUID, slot)
	
	
	
end

return module
