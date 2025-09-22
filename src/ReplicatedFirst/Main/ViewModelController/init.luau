local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local playersService = game:GetService("Players")
local localPlayer = playersService.LocalPlayer
local camera = workspace.CurrentCamera

local lib = require(replicatedStorage.lib)
local trove = lib.ModuleUtils.Trove

local assets = replicatedStorage:WaitForChild("Assets")
local viewModelFolder = assets:WaitForChild("ViewModels")
local simpleViewModel = viewModelFolder:WaitForChild("SimpleViewModel")

local clientManagers = replicatedStorage.Modules.Client.Managers
local viewModelManager = require(clientManagers.ViewModelManager)

local module = {}
module.Trove = trove.new()

function module.Init() end

function module.Start()
	viewModelManager.SetViewModel(simpleViewModel:Clone())

	module.Trove:Connect(runService.RenderStepped, function()
		local viewModel = viewModelManager.ViewModel
		if viewModel then
			local playerChar = localPlayer.Character
			if playerChar then
				viewModel:PivotTo(camera.CFrame)
			end
		end
	end)
end

return module
