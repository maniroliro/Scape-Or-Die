if not game:IsLoaded() then
	game.Loaded:Wait()
end

local replicatedStorage = game:GetService("ReplicatedStorage")
local lib = require(replicatedStorage.lib)

local modules = replicatedStorage.Modules
local remotes = lib.Remotes

local sharedServices = modules.Shared.Services
local instanceHandler = require(sharedServices.ReplicableInstancesHandler)

local playerData = require(script.PlayerDataController)
local inventoryS = require(script.InventoryController)

playerData.Start()
playerData.Init()

instanceHandler.Init()
instanceHandler.Start()

inventoryS.Init()
inventoryS.Start()

--local replicableInstance = require(replicatedStorage.Modules.Shared.Classes.ReplicableInstance)
--replicableInstance.Init()
--replicableInstance.Start()

remotes.PlayerLoaded:Fire()