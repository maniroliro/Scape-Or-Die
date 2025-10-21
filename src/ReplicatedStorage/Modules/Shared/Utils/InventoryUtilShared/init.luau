local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local playersService = game:GetService("Players")
local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local instancesManager = require(replicatedStorage.Modules.Shared.Managers.InstancesManager)

local charUtil = lib.FunctionUtils.Character

local gameSettings = require(replicatedStorage.Modules.Shared.GameSettings)

local module = {}
module.checks = {}

local maxItensOnInventory = 6

local function getPlayer(plr: Player?)
	if t.Player(plr) then
		return plr
	else
		if runService:IsServer() then
			warn("Player is not defined")
			return
		end
		return playersService.LocalPlayer
	end
end

function module.getPlayerInventory(plr: Player?): { any }
	plr = getPlayer(plr)
	if not plr then
		return {}
	end
	if runService:IsServer() then
		return require(game.ServerStorage.Modules.Managers.PlayerDataManager).getProfileData(plr).inventory
	end
	return require(game:GetService("ReplicatedStorage").Modules.Client.PlayerData).GetData().inventory
end

function module.checks.findItemInInventory(inv: { any }, itemUID: string)
	if not itemUID then
		return
	end
	if not inv then
		return
	end

	for k, v in inv do
		if v == itemUID then
			return k
		end
	end
	return nil
end

function module.checks.hasSpaceOnInventory(inv: { any })
	if not inv or type(inv) ~= "table" then
		return
	end
	local count = 0
	for _ in inv do
		count += 1
	end
	return count < 6
end

function module.checks.isSlotFree(inv: { any }, slot: number)
	if not inv or type(inv) ~= "table" or type(slot) ~= "number" then
		return
	end
	return not inv[slot]
end

function module.checks.isOnRange(itemUID: string, plr: Player)
	plr = getPlayer(plr)
	if not itemUID or not plr then
		return
	end
	local item = instancesManager.getObj(itemUID)
	if not item then
		return
	end

	local itemInstantiatedTo = item.InstantiatedTo
	local pos
	if type(itemInstantiatedTo) == "string" then
		if itemInstantiatedTo == "" then
			pos = item.Position
		else
			local chest = instancesManager.getObj(itemInstantiatedTo)
			if chest then
				pos = chest.PrimaryPart.Position
			end
		end
	end

	local hrp = charUtil.getAlivePlayerRootPart(plr)

	if hrp and pos and (hrp.Position - pos).Magnitude <= gameSettings.MaxDistanceToGetAnItem then
		return true
	end
end

function module.checks.isOnRay()
	-- TODO Raycast to the item/chest
end

function module.getNextSlotForANewItem(inv: { any })
	if not inv or type(inv) ~= "table" then
		return
	end
	if not module.checks.hasSpaceOnInventory(inv) then
		return
	end
	for i = 2, maxItensOnInventory do
		if module.checks.isSlotFree(inv, i) then
			return i
		end
	end
	if module.checks.isSlotFree(inv, 1) then
		return 1
	end
	return nil
end

function module.canAddItem(inv: { any }, itemUID: string)
	if not itemUID then
		return
	end
	if not inv or type(inv) ~= "table" then
		return
	end
	if not module.getNextSlotForANewItem(inv) then
		return
	end

	local item = instancesManager.getObj(itemUID)
	if not item then
		return
	end

	-- if not t.Player(item.InstantiatedTo) then
	-- 	return
	-- end
	if module.checks.findItemInInventory(inv, itemUID) then
		return
	end

	return true
end

function module.canEquipItem(inv: { any }, itemUID: string)
	if not t.table(inv) or not t.string(itemUID) then
		return
	end

	local pos = module.checks.findItemInInventory(inv, itemUID)
	if not pos then
		return
	end

	if inv[1] == itemUID then
		return
	end

	module.toggleEquip(inv, pos, 1)

	return true
end

function module.equipItem(itemUID: string, plr: Player?) end

function module.unequipItem(itemUID: string, plr: Player?) end

function module.isFirstItemIlegal(inv: { any })
	if type(inv) ~= "table" then
		return
	end
	local firstItemUID = inv[1]
	if not firstItemUID then
		return
	end
	local item = instancesManager.getObj(firstItemUID)
	if not item then
		return
	end
	if not item:IsA("Item") then
		return
	end

	return not item.Legal
end

function module.isThereAnIlegalItemOnInventory(inv: { any })
	if type(inv) ~= "table" then
		return
	end
	for _, uid in inv do
		local item = instancesManager.getObj(uid)
		if not item then
			continue
		end
		if not item:IsA("Item") then
			continue
		end
		if not item.Legal then
			return true
		end
	end
	return false
end

function module.normalizeToggleSlots(inv: { any }, pos1: number, pos2: number?)
	if not t.table(inv) or not t.number(pos1) then
		return
	end
	pos2 = pos2 or (pos1 == 1 and module.getNextSlotForANewItem(inv) or 1)
	if not t.number(pos2) then
		return
	end
	if pos1 == pos2 then
		return
	end

	if pos1 == 1 then
		pos1, pos2 = pos2 :: number, pos1
	end

	return pos1, pos2
end

function module.toggleEquip(inv: { any }, pos1: number, pos2: number?)
	pos1, pos2 = module.normalizeToggleSlots(inv, pos1, pos2)
	if not pos1 and not pos2 then
		return
	end
	local uid1 = inv[pos1 :: number]
	local uid2 = inv[pos2 :: number]
	inv[pos2 :: number], inv[pos1 :: number] = uid1, uid2

	local obj1 = uid1 and instancesManager.getObj(uid1)
	local obj2 = uid2 and instancesManager.getObj(uid2)
	print(obj1, obj2)
	if obj1 and (obj1 :: any).ToggleEquip then
		(obj1 :: any):ToggleEquip(pos2)
	end
	if obj2 and (obj2 :: any).ToggleEquip then
		(obj2 :: any):ToggleEquip(pos1)
	end

	return true
end

function module.addItemToInventory(itemUID: string, inv: { any }, pos: number?)
	local item = instancesManager.getObj(itemUID)
	if not item then
		return
	end
	if not module.canAddItem(inv, itemUID) then
		return
	end

	pos = pos or module.getNextSlotForANewItem(inv)
	if not pos then
		return
	end
	inv[pos] = itemUID
end

function module.removeItem(inv: { any }, itemUID: string)
	if not itemUID or not inv then
		return
	end

	local pos = module.checks.findItemInInventory(inv, itemUID)
	if not pos then
		return
	end

	inv[pos] = nil
	return true
end

function module.getItemSlot(inv: { any }, itemUID: string)
	if not itemUID or not inv then
		return
	end
	if type(inv) ~= "table" then
		return
	end

	for i, UID in inv do
		if UID == itemUID then
			return i
		end
	end

	return nil
end

return module
