local serverStorage = game:GetService("ServerStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")
local replicatedStoragemodules = replicatedStorage.Modules
local serverStoragemodules = serverStorage.Modules

local Classes = serverStoragemodules.Classes
local secCamClasse = require(Classes.SecurityCamera)
local chestClasse = require(Classes.Chest)
local itemClasse = require(Classes.Item)
local ilegalItemDetectorClass = require(Classes.IlegalItemDetector)

local serverServicesFolder = serverStoragemodules.Services
local replicatedStorageServicesFolder = replicatedStoragemodules.Shared.Services
local playerDataService = require(serverServicesFolder.PlayerDataService)
local inventoryService = require(serverServicesFolder.InventoryService)
local replicableInstancesHandler = require(replicatedStorageServicesFolder.ReplicableInstancesHandler)
local characterBehaviorService = require(serverServicesFolder.CharacterBehaviorService)

local directoryFolder = replicatedStorage.Directory
local itemDirectory = require(directoryFolder.Items)

playerDataService.Init()
playerDataService.Start()

inventoryService.Init()
inventoryService.Start()

replicableInstancesHandler.Init()
replicableInstancesHandler.Start()

characterBehaviorService.Init()
characterBehaviorService.Start()

local plr
local cam = secCamClasse.new()
local chest1 = chestClasse.new(01)
local chest2 = chestClasse.new(01)
local chest3 = chestClasse.new(01)

cam:AttachCameraArea(workspace.Area1)
cam:start()

chest1:Replicate()
chest1:Materialize(workspace.bau1.CFrame)

for _ = 1, math.random(3, 12) do
	local newItem = itemClasse.new()
	newItem:AttachId(itemDirectory:getRandomItemId())

	chest1:AddItem(newItem.UID)
	print(chest1, chest1.UID, chest1.ItemsInside, newItem.UID)
end
for _ = 1, math.random(2, 6) do
	local newItem = itemClasse.new()
	newItem:AttachId(itemDirectory:getRandomItemId())

	chest1:AddItem(newItem.UID, "HiddenContents")
end

chest2:Replicate()
chest2:Materialize(workspace.bau2.CFrame)

for _ = 1, math.random(3, 12) do
	local newItem = itemClasse.new()
	newItem:AttachId(itemDirectory:getRandomItemId())

	chest2:AddItem(newItem.UID)
	print(chest2, chest2.UID, chest2.ItemsInside, newItem.UID)
end
for _ = 1, math.random(2, 6) do
	local newItem = itemClasse.new()
	newItem:AttachId(itemDirectory:getRandomItemId())

	chest2:AddItem(newItem.UID, "HiddenContents")
end

chest3:Replicate()
chest3:Materialize(workspace.bau3.CFrame)

for _ = 1, math.random(3, 12) do
	local newItem = itemClasse.new()
	newItem:AttachId(itemDirectory:getRandomItemId())

	chest3:AddItem(newItem.UID)
	print(chest3, chest3.UID, chest3.ItemsInside, newItem.UID)
end
for _ = 1, math.random(2, 6) do
	local newItem = itemClasse.new()
	newItem:AttachId(itemDirectory:getRandomItemId())

	chest3:AddItem(newItem.UID, "HiddenContents")
end

local itemDetector1 = ilegalItemDetectorClass.new()
itemDetector1:Replicate(true)
itemDetector1:AttachId(1)
itemDetector1:Materialize(workspace.md1.CFrame)
itemDetector1:Active()

local itemDetector2 = ilegalItemDetectorClass.new()
itemDetector2:Replicate(true)
itemDetector2:AttachId(1)
itemDetector2:Materialize(workspace.md2.CFrame)
itemDetector2:Active()

plr = game.Players.PlayerAdded:Wait()
chest1:SetOwner(plr)

--table.insert(instances, cam)
--table.insert(instances, chest)

--print(instances)

--print(lib.Utils.ReplicableInstance.objsCreated)
