local serverStorage = game:GetService("ServerStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")
local replicatedStoragemodules = replicatedStorage.Modules
local serverStoragemodules = serverStorage.Modules

local Classes = serverStoragemodules.Classes
local securityCameraClass = require(Classes.SecurityCamera)
local chestClass = require(Classes.Chest)
local itemClass = require(Classes.Item)
local scannerClass = require(Classes.Scanner)
local wallClass = require(Classes.Wall)
local guardClass = require(Classes.Guard)

local serverServicesFolder = serverStoragemodules.Services
local replicatedStorageServicesFolder = replicatedStoragemodules.Shared.Services
local playerDataService = require(serverServicesFolder.PlayerDataService)
local inventoryService = require(serverServicesFolder.InventoryService)
local replicableInstancesHandler = require(replicatedStorageServicesFolder.ReplicableInstancesHandler)
local characterBehaviorService = require(serverServicesFolder.CharacterBehaviorService)
local physicsService = require(serverServicesFolder.PhysicsService)
local remoteResponse = require(serverServicesFolder.RemotesResponse)
local gameCharacterService = require(serverServicesFolder.GameCharacterService)

local directoryFolder = replicatedStorage.Directory
local itemDirectory = require(directoryFolder.Items)
local wallDir = require(directoryFolder.Walls)

local splitPartIntoGrid = require(replicatedStorage.Modules.Shared.Utils.GetSplittedPartsInGrid)

playerDataService.Init()
inventoryService.Init()
replicableInstancesHandler.Init()
characterBehaviorService.Init()
physicsService.Init()
remoteResponse.Init()

playerDataService.Start()
inventoryService.Start()
replicableInstancesHandler.Start()
characterBehaviorService.Start()
physicsService.Start()
remoteResponse.Start()

local chest1 = chestClass.new(01)
local chest2 = chestClass.new(01)
local chest3 = chestClass.new(01)

chest1:Replicate(true)
chest1:Materialize({ CFrame = workspace.bau1.CFrame })

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

chest2:Replicate(true)
chest2:Materialize({ CFrame = workspace.bau2.CFrame })

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

chest3:Replicate(true)
chest3:Materialize({ CFrame = workspace.bau3.CFrame })

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

local itemDetector1 = scannerClass.new()
itemDetector1:AttachId(1)
itemDetector1:Materialize({ CFrame = workspace.md1.CFrame })
itemDetector1:Active()
itemDetector1:Replicate(true)

local itemDetector2 = scannerClass.new()
itemDetector2:AttachId(1)
itemDetector2:Materialize({ CFrame = workspace.md2.CFrame })
itemDetector2:Active()
itemDetector2:Replicate(true)

local plr = game.Players.PlayerAdded:Wait()
chest1:SetOwner(plr)

-- SecurityCamera

local cam = securityCameraClass.new()
cam:AttachId(01)
cam:Materialize({ Model = workspace.WallToCam })
cam:AttachCameraZone(workspace.AreaToAttach)
cam:Active(true)
cam:Replicate(true)

local cam2 = securityCameraClass.new()
cam2:AttachId(02)
cam2:Materialize({ Model = workspace.WallToCam2 })
cam2:AttachCameraZone(workspace.AreaToAttach2)
cam2:Active(true)
cam2:Replicate(true)

local cam3 = securityCameraClass.new()
cam3:AttachId(02)
cam3:Materialize({ Model = workspace.WallToCam3 })
cam3:AttachCameraZone(workspace.ahaaa)
cam3:Active(true)
cam3:Replicate(true)

--  Walls

local allParts = splitPartIntoGrid(workspace.theWallTestSizeDiv)
for _, p in pairs(allParts) do
	local mat = p.Material.Name
	local id = wallDir:getIdByName(mat)
	local newWall = wallClass.new(id)
	newWall:Materialize({ Model = p })

	newWall:Replicate(true)
	print(p)
end

-- Guards

local guard1 = guardClass.new(00)
guard1:Materialize({ Model = CFrame.new(0, 5, 0) })
guard1:StartWorking()

guard1:Replicate(false)
