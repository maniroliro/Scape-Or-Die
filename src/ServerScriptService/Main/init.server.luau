local serverStorage = game:GetService("ServerStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")
local replicatedStoragemodules = replicatedStorage.Modules
local serverStoragemodules = serverStorage.Modules

local Classes = serverStoragemodules.Classes
local securityCameraClass = require(Classes.SecurityCamera)
local chestClass = require(Classes.Chest)
local itemClass = require(Classes.Item)
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
local chest1 = chestClass.new(01)
local chest2 = chestClass.new(01)
local chest3 = chestClass.new(01)

chest1:Replicate()
chest1:Materialize(workspace.bau1.CFrame)

for _ = 1, math.random(3, 12) do
	local newItem = itemClass.new()
	newItem:AttachId(itemDirectory:getRandomItemId())

	chest1:AddItem(newItem.UID)
end
for _ = 1, math.random(2, 6) do
	local newItem = itemClass.new()
	newItem:AttachId(itemDirectory:getRandomItemId())

	chest1:AddItem(newItem.UID, "HiddenContents")
end

chest2:Replicate()
chest2:Materialize(workspace.bau2.CFrame)

for _ = 1, math.random(3, 12) do
	local newItem = itemClass.new()
	newItem:AttachId(itemDirectory:getRandomItemId())

	chest2:AddItem(newItem.UID)
end
for _ = 1, math.random(2, 6) do
	local newItem = itemClass.new()
	newItem:AttachId(itemDirectory:getRandomItemId())

	chest2:AddItem(newItem.UID, "HiddenContents")
end

chest3:Replicate()
chest3:Materialize(workspace.bau3.CFrame)

for _ = 1, math.random(3, 12) do
	local newItem = itemClass.new()
	newItem:AttachId(itemDirectory:getRandomItemId())

	chest3:AddItem(newItem.UID)
end
for _ = 1, math.random(2, 6) do
	local newItem = itemClass.new()
	newItem:AttachId(itemDirectory:getRandomItemId())

	chest3:AddItem(newItem.UID, "HiddenContents")
end

-- ItemDetector

local itemDetector1 = ilegalItemDetectorClass.new()
itemDetector1:AttachId(1)
itemDetector1:Materialize(workspace.md1.CFrame)
itemDetector1:Active()
itemDetector1:Replicate(true)

local itemDetector2 = ilegalItemDetectorClass.new()
itemDetector2:AttachId(1)
itemDetector2:Materialize(workspace.md2.CFrame)
itemDetector2:Active()
itemDetector2:Replicate(true)

plr = game.Players.PlayerAdded:Wait()
--chest1:SetOwner(plr)

-- SecurityCamera

local cam = securityCameraClass.new()
cam:AttachId(01)
cam:Materialize(workspace.WallToCam)
cam:AttachCameraZone(workspace.AreaToAttach)
cam:Active(true)
cam:Replicate(true)

local cam2 = securityCameraClass.new()
cam2:AttachId(02)
cam2:Materialize(workspace.WallToCam2)
cam2:AttachCameraZone(workspace.AreaToAttach2)
cam2:Active(true)
cam2:Replicate(true)

local cam3 = securityCameraClass.new()
cam3:AttachId(02)
cam3:Materialize(workspace.WallToCam3)
cam3:AttachCameraZone(workspace.ahaaa)
cam3:Active(true)
cam3:Replicate(true)

--table.insert(instances, cam)
--table.insert(instances, chest)

--print(instances)

--print(lib.Utils.ReplicableInstance.objsCreated)
