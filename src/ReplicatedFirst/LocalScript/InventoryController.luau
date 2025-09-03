local replicatedStorage = game:GetService('ReplicatedStorage')
local userInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer

local lib = require(replicatedStorage:WaitForChild('lib'))
local inventoryUtilShared = require(replicatedStorage.Modules.Shared.Utils.InventoryUtilShared)
local replicableInstance = require(replicatedStorage.Modules.Shared.Classes.ReplicableInstance)

local playerData = require(replicatedStorage.Modules.Client.PlayerData)

local module = {}
module.inventoryItems = {}
module.equippeditem = nil

local acceptableInputs = {
	One = 1,
	Two = 2,
	Three = 3,
	Four = 4,
	Five = 5,
	Six = 6,
}

function module.Init()

end

function module.Start()
	--userInputService.InputBegan:Connect(function(inp)
	--	local acceptableInp = acceptableInputs[inp.KeyCode.Name]
	--	if acceptableInp then
	--		inventoryUtilShared.toggleEquip(acceptableInp)
	--	end
	--end)
	--playerData.NewDataReceived:Connect(function(data)
	--	print('analize')
	--	local oldData = playerData.Data
	--	for i, currentItemUID in data.inventory do
	--		local previousItemUID = oldData.inventory[i]
	--		if previousItemUID == currentItemUID then continue end
	--		local item = instancesManager.getObj(currentItemUID)
	--		local pos = table.find(oldData, currentItemUID)
	--		if pos then
	--			inventoryUtilShared.toggleEquip(player, pos, i)
	--		else
				
	--		end
	--	end
	--end)
end

return module