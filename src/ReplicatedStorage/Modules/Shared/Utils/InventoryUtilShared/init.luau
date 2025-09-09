local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local playersService = game:GetService('Players')
local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local instancesManager = require(replicatedStorage.Modules.Shared.Managers.InstancesManager)

local charUtil = lib.FunctionUtils.Character

local gameSettings = require(replicatedStorage.Modules.Shared.GameSettings)

local module = {}
module.checks = {}

local maxItensOnInventory = 6

local function getPlayer(plr: Player?)
	if t.Instance(plr) and plr:IsA('Player') then
		return plr
	else
		if runService:IsServer() then
			warn('Player is not defined')
			return
		end
		return playersService.LocalPlayer
	end
end

function module.getPlayerInventory(plr:Player?) : {any}
	plr = getPlayer(plr)
	if not plr then return end
	if runService:IsServer() then
		return require(game.ServerStorage.Modules.Managers.PlayerDataManager).getProfileData(plr).inventory
	end
	return require(game:GetService('ReplicatedStorage').Modules.Client.PlayerData).GetData().inventory
end

function module.checks.findItemInInventory(inv: {any}, itemUID: string)
	if not itemUID then return end
	if not inv then return end
	
	for k, v in inv do
		if v.UID == itemUID then
			return k
		end
	end
	return nil
end

function module.checks.hasSpaceOnInventory(inv: {any})
	if not inv or type(inv) ~= 'table' then return end
	local t = 0
	for k, v in inv do
		t += 1
	end
	return t < 6
end

function module.checks.isSlotFree(inv: {any}, slot: number)
	if not inv or type(inv) ~= 'table' or type(slot) ~= 'number' then return end
	return not inv[slot]
end

function module.checks.isOnRange(itemUID: string, plr: Player)
	plr = getPlayer(plr)
	if not itemUID or not plr then return end
	local item = instancesManager.getObj(itemUID)
	if not item then return end
	
	local itemInstantiatedTo = item.InstantiatedTo
	local pos
	if type(itemInstantiatedTo) == 'string' then
		if itemInstantiatedTo == '' then
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

function module.getNextSlotForANewItem(inv: {any})
	if not inv or type(inv) ~= 'table' then return end
	if not module.checks.hasSpaceOnInventory(inv) then return end
	for i = 2, maxItensOnInventory do
		if module.checks.isSlotFree(inv, i) then
			return i
		end
	end
	if module.checks.isSlotFree(inv, 1) then return 1 end
end

function module.canAddItem(inv: {any}, itemUID: string)
	if not itemUID then return end
	if not inv or type(inv) ~= 'table' then return end
	if not module.getNextSlotForANewItem(inv) then return end

	local item = instancesManager.getObj(itemUID)
	if not item then return end

	if type(item.InstantiatedTo) ~= 'string' then return end
	if module.checks.findItemInInventory(inv, itemUID) then return end

	return true
end

function module.canRemoveItem(inv: {any}, itemUID: string)
	if type(inv) ~= 'table' or not itemUID then return end
	local item = instancesManager.getObj(itemUID)
	if not item then return end
end

function module.equipItem(itemUID: string, plr: Player?)

end

function module.unequipItem(itemUID: string, plr: Player?)


end

function module.isThereAnIlegalItemOnInventory(inv: {any})
	if type(inv) ~= 'table' then return end
	for i, uid in inv do
		local item = instancesManager.getObj(uid)
		if not item then continue end
		if item._Type ~= 'Item' then return end
		if not item.Legal then return true end
	end
	return false
end

function module.toggleEquip(inv: {any}, pos1: number, pos2: number)
	if not pos1 then return end
	if not pos2 then pos2 = 1 end
	
	inv[pos2], inv[pos1] = inv[pos1], inv[pos2]
	
	if inv[1] == inv[pos1] then
		inv[pos2].UnequipItem()
		inv[pos1].EquipItem()
	end
	if inv[1] == inv[pos2] then
		inv[pos1].UnequipItem()
		inv[pos2].EquipItem()
	end
end

function module.addItemToInventory(itemUID: string, inv: {any}, pos: number?)
	if not module.canAddItem(inv, itemUID) then return end
	local item = instancesManager.getObj(itemUID)
	if not item then return end
	
	local pos = pos or module.getNextSlotForANewItem(inv)
	if not pos then return end
	print('add', inv, pos, itemUID)
	inv[pos] = itemUID 
end

function module.removeItem(inv: {any}, itemUID: string)
	if not itemUID and not inv then return end
	if not module.canRemoveItem(inv, itemUID) then return end
	
	for i, UID in inv do
		if UID == itemUID then
			inv[i] = nil
			return
		end
	end
end

function module.getItemSlot(inv: {any}, itemUID: string)
	if not itemUID or not inv then return end
	if type(inv) ~= 'table' then return end
	
	for i, UID in inv do
		if UID == itemUID then
			return i
		end
	end

	return nil
end


return module
