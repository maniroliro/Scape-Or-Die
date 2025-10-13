local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local playerGUI = player:WaitForChild("PlayerGui") :: PlayerGui

local lib = require(replicatedStorage:WaitForChild("lib"))
local trove = lib.ModuleUtils.Trove

local createTabSystem = require(replicatedStorage.Modules.Client.Utils.TabSystem)

local module = {}
module.Trove = trove.new()
module.ObjTrove = trove.new()
module.Display = playerGUI:WaitForChild("Menu")
module.CloseDisplayButtonConnection = nil
module.MouseBehaviorConnection = nil
module.isMenuActivated = false

module.tabSystem =
	createTabSystem(module.Display.Frame.Menu.Frame.Tabs, module.Display.Frame.Menu.Frame.Contents, script)
module.ObjTrove = module.tabSystem.Trove

function module.ActiveMenu()
	module.isMenuActivated = true
	module.Display.Enabled = true
	print("unlocking mouse")
	module.Display.Frame.Modal.Visible = true

	if not module.CloseDisplayButtonConnection then
		module.CloseDisplayButtonConnection =
			module.Trove:Add((module.Display.Frame.Modal :: GuiButton).Activated:Connect(function()
				print("Close button clicked")

				module.toggleMenuActive()
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
end

function module.DisableMenu()
	module.isMenuActivated = false
	module.Display.Enabled = false
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

function module.toggleMenuActive(tabName: string?)
	if tabName then
		module.tabSystem.toggleTabActive(tabName)
	end
	module.Display.Enabled = not module.Display.Enabled
	print("toggling")

	if module.Display.Enabled then
		module.ActiveMenu()
	else
		module.DisableMenu()
	end
end

return module
