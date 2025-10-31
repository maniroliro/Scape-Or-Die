local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local starterGui = game:GetService("StarterGui")

local menuUiManager = require(replicatedStorage.Modules.Client.Managers.MenuUIManager)

local lib = require(replicatedStorage:WaitForChild("lib"))
local trove = lib.ModuleUtils.Trove

local module = {}
module.Trove = trove.new()
module.CloseDisplayButtonConnection = nil
module.MouseBehaviorConnection = nil

function module.Init()
	menuUiManager.Init()
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
end

function module.Start()
	menuUiManager.Start()
	menuUiManager.tabSystem.toggleTabActive("Profile")
	module.Trove:Connect(userInputService.InputBegan, function(input, gameProcessed)
		if gameProcessed then
			print("gameProcessed")
			return
		end
		print(input.KeyCode)
		if input.KeyCode == Enum.KeyCode.Tab then
			menuUiManager.toggleMenuActive("Profile")
		end
	end)
end

return module
