local replicatedStorage = game:GetService('ReplicatedStorage')
local serverStorage = game:GetService('ServerStorage')
local lib = require(replicatedStorage.lib)
local InventoryUtilShared = require(replicatedStorage.Modules.Shared.Utils.InventoryUtilShared)
local remotes = lib.Remotes
local instancesManager = require(replicatedStorage.Modules.Shared.Managers.InstancesManager)
local charUtil = lib.FunctionUtils.Character
local playerDataManager = require(serverStorage.Modules.Managers.PlayerDataManager)
local GameSettings = require(replicatedStorage.Modules.Shared.GameSettings)

local MaxDistanceToGetAnItem = GameSettings.MaxDistanceToGetAnItem

local module = {}

function module.Init()
	
end

function module.Start()
	remotes.AddItemToInventory.OnServerEvent:Connect(function(plr: Player, itemUID: string)
		local plrInv = InventoryUtilShared.getPlayerInventory(plr)
		if not plrInv then return end
		if InventoryUtilShared.hasSpaceOnInventory(plrInv) then
			local item = instancesManager.getObj(itemUID)
			local itemParent = item.InstantiatedTo
			if itemParent then
				if type(itemParent) == 'string' then
					local cf
					local pos
					local whereInChest
					local dist
					if itemParent == '' then
						cf = item.CFrame
						dist = MaxDistanceToGetAnItem
					else
						itemParent = instancesManager.getObj(itemParent)
						if itemParent._Type == 'Chest' then
							if itemParent.PlayerOwner == plr then
								pos = table.find(itemParent.ItemsInside.HiddenContents, itemUID)
								whereInChest = itemParent.ItemsInside.HiddenContents
								dist = itemParent.MaxDistanceToInteract
							end
							if not pos then
								pos = table.find(itemParent.ItemsInside.DeskContents, itemUID)
								whereInChest = itemParent.ItemsInside.DeskContents
								dist = itemParent.MaxDistanceToInteract
							end
							if not pos then
								warn('item '.. itemUID.. ' does not have a chest as a parent anymore')
								return
							end
							cf = itemParent.CFrame
						end
					end
					local rootPart = charUtil.getAlivePlayerRootPart(plr)
					if rootPart and (rootPart.Position - cf.Position).Magnitude <= dist then
						if pos then 
							table.remove(whereInChest, pos) 
						end
						item:InstantiateTo(plr)
						InventoryUtilShared.addItem(itemUID, plr)
					end
				end
			end
		end
	end)
end

return module
