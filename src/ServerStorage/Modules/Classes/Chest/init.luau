local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t

local replicableInstance = require(sharedModules.Classes.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)
local charUtils = lib.FunctionUtils.Character

local chestSharedClass = require(sharedModules.Classes.ChestClasse)

local module = setmetatable({}, { __index = chestSharedClass })

local Storages = {
	DeskContents = {
		Name = "DeskContents",
		MaxAmountOfItems = 12,
	},
	HiddenContents = {
		Name = "HiddenContents",
		MaxAmountOfItems = 6,
	},
}

export type Storages = "DeskContents" | "HiddenContents"

export type ChestItems = chestSharedClass.ChestItems

export type ClassType = typeof(setmetatable(
	{} :: {
		PlayersSearching: { Player | nil },
		SendPlayerItemsInsideThread: thread?,
	},
	{ __index = module }
)) & chestSharedClass.ClassType

function module.new(id: string | number?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, chestSharedClass) :: ClassType
	self.PlayersSearching = {}

	if id then
		self:AttachId(id)
	end
	return self
end

function module.AttachId(self: ClassType, _id: string | number)
	self.Remote:Fire(self.UID, "AttachChest", { self.Id })
	return self
end

function module.getNextFreeSlot(self: ClassType, contentName: Storages)
	if not contentName then
		return
	end
	local itemsInside = self.ItemsInside
	local chestStorage = itemsInside[contentName]
	local maxNOfItems = Storages[contentName].MaxAmountOfItems
	if maxNOfItems <= #chestStorage then
		return self
	end

	print(#chestStorage)
	for i = 1, maxNOfItems do
		local uid = chestStorage[i]
		if not uid then
			return i
		end
	end

	return self
end

function module.UpdatePlayerItemsInside(self: ClassType, plr: Player, nothing: boolean?): ClassType
	if nothing then
		self.Remote:FireClient(plr, self.UID, "UpdateItemsInside", { { DeskContents = {}, HiddenContents = {} } })
	else
		print(self.PlayerOwner)
		local tabToSend = {}
		local itemsInside = self.ItemsInside
		for contentName, contentTab in itemsInside do
			local owner = self.PlayerOwner
			if owner and owner ~= plr and contentName == "HiddenContents" then
				continue
			end
			tabToSend[contentName] = {}
			for _, itemUID in contentTab do
				table.insert(tabToSend[contentName], itemUID)
				local item = instancesManager.getObj(itemUID)
				if item then
					item:Replicate(true)
				end
			end
		end
		print(tabToSend)
		self.Remote:FireClient(plr, self.UID, "UpdateItemsInside", { tabToSend })
	end
	return self
end

function module.UpdatePlayerSearchingItemsInside(self: ClassType)
	if not #self.PlayersSearching then
		return self
	end
	local plrs = self.PlayersSearching
	for _, plr in plrs do
		self:UpdatePlayerItemsInside(plr)
	end

	return self
end

function module.AddItem(self: ClassType, itemUID: string, contentName: Storages)
	if not itemUID then
		return self
	end
	local item = instancesManager.getObj(itemUID)
	if not item then
		return self
	end
	contentName = contentName or "DeskContents"

	local itemsInside = self.ItemsInside
	local contentTab = itemsInside[contentName]
	if table.find(contentTab, itemUID) then
		return self
	end

	local pos = self:getNextFreeSlot(contentName)
	if pos then
		contentTab[pos] = itemUID
		item:InstantiateTo(self.UID, contentName)
	end

	self:UpdatePlayerSearchingItemsInside()
	return self
end

function module.RemoveItem(self: ClassType, itemUID: string, contentName: Storages?)
	print("REMOVE")
	print(itemUID)
	print(self.ItemsInside)
	if contentName then
		local itemsInside = self.ItemsInside
		local chestStorage = itemsInside[contentName]
		local pos = table.find(chestStorage, itemUID)
		if pos then
			chestStorage[pos] = nil
		end
	else
		print()
		local itemsInside = self.ItemsInside
		for _, storage in itemsInside do
			local pos = table.find(storage, itemUID)
			print(storage)
			print(pos)
			if pos then
				print(storage[pos])
				storage[pos] = nil
				return self
			end
		end
	end
	print(self.ItemsInside)

	self:UpdatePlayerSearchingItemsInside()
	return self
end

function module.UpdatePlayerSearching(self: ClassType, plr: Player)
	if not t.Player(plr) then
		return self
	end

	local findPlayer = table.find(self.PlayersSearching, plr)
	local value = not findPlayer and self.UID or nil

	if findPlayer then
		table.remove(self.PlayersSearching, findPlayer)
	else
		table.insert(self.PlayersSearching, plr)
	end

	plr:SetAttribute("ChestOpen", value)
	return self
end

function module.playerBeganHoldingProximityPrompt(self: ClassType, plr: Player)
	local playerPing = plr:GetNetworkPing()

	--local plrRootPart = charUtils.getAlivePlayerRootPart(plr)
	--print((plrRootPart.Position - self.CFrame.Position).Magnitude, self.MaxDistanceToInteract + 0.2)
	--if plrRootPart and (plrRootPart.Position - self.CFrame.Position).Magnitude <= self.MaxDistanceToInteract + 0.2 then
	local con

	self.SendPlayerItemsInsideThread = task.delay(self.OpenTime - playerPing * 4 - 0.1, function()
		self.SendPlayerItemsInsideThread = nil
		con:Disconnect()

		local con2
		con2 = runService.Heartbeat:Connect(function()
			local plrRootPart = charUtils.getAlivePlayerRootPart(plr)
			if
				not plrRootPart
				or (plrRootPart.Position - self.CFrame.Position).Magnitude >= self.MaxDistanceToInteract
			then
				con2:Disconnect()
				con2 = nil
				plr:SetAttribute("ChestOpen", nil)
				self:UpdatePlayerItemsInside(plr, true)
				return
			end
		end)
		self.Trove:Add(con2)

		local plrRootPart = charUtils.getAlivePlayerRootPart(plr)
		if not plrRootPart or (plrRootPart.Position - self.CFrame.Position).Magnitude >= self.MaxDistanceToInteract then
			return
		end

		plr:SetAttribute("ChestOpen", self.UID)
		self:UpdatePlayerItemsInside(plr, false)
	end)

	con = runService.Heartbeat:Connect(function()
		local plrRootPart = charUtils.getAlivePlayerRootPart(plr)
		if not plrRootPart or (plrRootPart.Position - self.CFrame.Position).Magnitude >= self.MaxDistanceToInteract then
			con:Disconnect()
			con = nil
			self:playerEndedHoldingProximityPrompt(plr)
			return
		end
	end)
	self.Trove:Add(con)
	--end

	return self
end

function module.SetOwner(self: ClassType, plr: Player?)
	if not t.Player(plr) then
		return self
	end
	self.Remote:Fire(self.UID, "SetOwner", { self.PlayerOwner })
	return self
end

function module.playerEndedHoldingProximityPrompt(self: ClassType, plr: Player)
	if self.SendPlayerItemsInsideThread then
		task.cancel(self.SendPlayerItemsInsideThread)
		self.SendPlayerItemsInsideThread = nil
		plr:SetAttribute("ChestOpen", nil)
		self:UpdatePlayerItemsInside(plr, true)
	end

	return self
end

function module.Materialize(self: ClassType, CF: CFrame)
	if not t.CFrame(CF) then
		return self
	end
	self.Remote:Fire(self.UID, "Materialize", { self.CFrame })
	return self
end

function module.ReplicateTo(self: ClassType, client: Player?)
	local newchest = lib.Remotes.instanceCreated.Chest

	if client then
		newchest:FireClient(client, self.UID)

		self.Remote:FireClient(client, self.UID, "AttachChest", { self.Id })
		self.Remote:FireClient(client, self.UID, "Materialize", { self.CFrame })
	else
		newchest:Fire(self.UID)

		self.Remote:Fire(self.UID, "AttachChest", { self.Id })
		self.Remote:Fire(self.UID, "Materialize", { self.CFrame })
	end

	return self
end

return module
