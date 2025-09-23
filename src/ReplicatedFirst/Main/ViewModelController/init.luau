local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local playersService = game:GetService("Players")
local localPlayer = playersService.LocalPlayer
local camera = workspace.CurrentCamera

local lib = require(replicatedStorage.lib)
local trove = lib.ModuleUtils.Trove
local charUtil = lib.FunctionUtils.Character

local assets = replicatedStorage:WaitForChild("Assets")
local viewModelFolder = assets:WaitForChild("ViewModels")
local simpleViewModel = viewModelFolder:WaitForChild("SimpleViewModel")

local clientManagers = replicatedStorage.Modules.Client.Managers
local viewModelManager = require(clientManagers.ViewModelManager)

local module = {}
module.Trove = trove.new()

module.bobbing = 0
module.stride = 0

local VIEW_MODEL_BOBBING_TRANSITION_SPEED = 10
local VIEW_MODEL_BOBBING_SPEED = 0.4
local VIEW_MODEL_BOBBING_AMOUNT = 0.05

local function lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

function module.Init() end

function module.Start()
	viewModelManager.SetViewModel(simpleViewModel:Clone())
	localPlayer.CameraMode = Enum.CameraMode.LockFirstPerson

	localPlayer.CharacterAdded:Once(function(char)
		for _, v in char:GetChildren() do
			if v:IsA("BasePart") then
				v.LocalTransparencyModifier = 0
			end
		end
	end)

	module.Trove:Connect(runService.RenderStepped, function(dt)
		local viewModel = viewModelManager.ViewModel
		if viewModel then
			local playerRootPart = charUtil.getAlivePlayerRootPart(localPlayer)
			if playerRootPart then
				--viewModel:PivotTo(camera.CFrame)
				print(playerRootPart)
				local vel = playerRootPart.AssemblyLinearVelocity

				local moveSpeed = (vel * Vector3.new(1, 0, 1)).Magnitude
				print(viewModel.Attachment)
				print(moveSpeed)
				local bobbingSpeed = moveSpeed * VIEW_MODEL_BOBBING_SPEED
				local bobbing = math.min(bobbingSpeed, 1)

				module.stride = (module.stride + bobbingSpeed * dt) % (math.pi * 2)
				module.bobbing = lerp(module.bobbing, bobbing, math.min(dt * VIEW_MODEL_BOBBING_TRANSITION_SPEED, 1))

				local x = math.sin(module.stride)
				local y = math.sin(module.stride * 2)
				local bobbingOffset = Vector3.new(x, y, 0) * VIEW_MODEL_BOBBING_AMOUNT * module.bobbing
				local bobbingCFrame = CFrame.new(bobbingOffset)
				print(bobbingOffset)

				local newCFrame = camera.CFrame * bobbingCFrame
				viewModel:PivotTo(newCFrame)
			end
		end
	end)
end

return module
