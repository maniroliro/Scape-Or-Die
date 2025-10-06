local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local starterGui = game:GetService("StarterGui")
local playerGUI = player:WaitForChild("PlayerGui") :: PlayerGui

local lib = require(replicatedStorage:WaitForChild("lib"))
local trove = lib.ModuleUtils.Trove

local createTabSystem = require(script.Utils.TabSystem)

local module = {}
module.Trove = trove.new()
module.ObjTrove = trove.new()
module.Display = playerGUI:WaitForChild("Menu")
module.CloseDisplayButtonConnection = nil

module.MouseBehaviorConnection = nil

function module.Init()
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
end

function toggleMenuActive()
	module.Display.Enabled = not module.Display.Enabled
	print("toggling")

	if module.Display.Enabled then
		print("unlocking mouse")
		module.Display.Frame.Modal.Visible = true

		if not module.CloseDisplayButtonConnection then
			module.CloseDisplayButtonConnection =
				module.Trove:Add((module.Display.Frame.Modal :: GuiButton).Activated:Connect(function()
					print("Close button clicked")

					toggleMenuActive()
				end))
		end

		if module.MouseBehaviorConnection then
			module.MouseBehaviorConnection:Disconnect()
			module.MouseBehaviorConnection = nil
		end

		userInputService.MouseBehavior = Enum.MouseBehavior.Default
		module.MouseBehaviorConnection = game:GetService("RunService").Heartbeat:Connect(function()
			userInputService.MouseBehavior = Enum.MouseBehavior.Default
		end)
	else
		print("locking mouse")
		module.Display.Frame.Modal.Visible = false
		if module.CloseDisplayButtonConnection then
			module.CloseDisplayButtonConnection:Disconnect()
			module.CloseDisplayButtonConnection = nil
		end

		if module.MouseBehaviorConnection then
			module.MouseBehaviorConnection:Disconnect()
			module.MouseBehaviorConnection = nil
		end

		userInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		module.MouseBehaviorConnection = game:GetService("RunService").Heartbeat:Connect(function()
			userInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		end)

		--module.ObjTrove:Destroy()
	end
end

function module.Start()
	local tabSystem =
		createTabSystem(module.Display.Frame.Menu.Frame.Tabs, module.Display.Frame.Menu.Frame.Contents, script)
	module.ObjTrove = tabSystem.Trove

	tabSystem.toggleTabActive("Profile")
	module.Trove:Connect(userInputService.InputBegan, function(input, gameProcessed)
		if gameProcessed then
			print("gameProcessed")
			return
		end
		print(input.KeyCode)
		if input.KeyCode == Enum.KeyCode.Tab then
			tabSystem.toggleTabActive("Profile")
			toggleMenuActive()
		end
	end)
end

return module
