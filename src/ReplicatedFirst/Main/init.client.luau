if not game:IsLoaded() then
	game.Loaded:Wait()
end

local replicatedStorage = game:GetService("ReplicatedStorage")
local lib = require(replicatedStorage.lib)

local modules = replicatedStorage.Modules
local remotes = lib.Remotes

local sharedServices = modules.Shared.Services
local instanceHandler = require(sharedServices.ReplicableInstancesHandler)

local playerDataController = require(script.PlayerDataController)
local inventoryController = require(script.InventoryController)
local playerInteractionsController = require(script.PlayerInteractionsController)
local viewModelController = require(script.ViewModelController)
local playerUIController = require(script.PlayerUIController)

playerDataController.Init()
instanceHandler.Init()
viewModelController.Init()
inventoryController.Init()
playerInteractionsController.Init()
playerUIController.Init()

playerDataController.Start()
instanceHandler.Start()
viewModelController.Start()
inventoryController.Start()
playerInteractionsController.Start()
playerUIController.Start()

--local replicableInstance = require(replicatedStorage.Modules.Shared.Classes.BaseClasses.ReplicableInstance)
--replicableInstance.Init()
--replicableInstance.Start()

remotes.PlayerLoaded:Fire()
