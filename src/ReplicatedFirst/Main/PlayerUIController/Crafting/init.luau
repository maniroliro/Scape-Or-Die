local ReplicatedStorage = game:GetService("ReplicatedStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local playerGUI = player:WaitForChild("PlayerGui") :: PlayerGui

local Crafts = require(ReplicatedStorage.Directory.Crafts)
local lib = require(replicatedStorage.lib)
local trove = lib.ModuleUtils.Trove

local createTabSystem = require(script.Parent.Utils.TabSystem)

local itemDirectory = replicatedStorage.Directory.Items
local itemReplicaModule = require(replicatedStorage.Modules.Client.Replicas.ItemReplica)

local module = {}
module.Display = playerGUI:WaitForChild("Menu").Frame.Menu.Frame.Contents.Crafting
module.Trove = trove.new()

module.Crafts = {
	intelligence30 = {},
	intelligence40 = {},
	intelligence50 = {},
	intelligence60 = {},
	intelligence70 = {},
}

function module.Init()
	print("Initializing Crafting UI")
	local firstDiv = module.Display.Frame.Frame.First
	for _, itemModule in itemDirectory:GetChildren() do
		print()
		if itemModule:IsA("ModuleScript") then
			print()
			local item = require(itemModule)
			if item and item.Crafts and #item.Crafts > 0 then
				print()
				for i, craft in item.Crafts do
					print(craft)
					local intelligenceRequired = craft.intelligenceRequired
					local itemReplica: itemReplicaModule.ClassType = itemReplicaModule.new()
					itemReplica:AttachId(item.Id)
					itemReplica:CreateDisplay()
					print(firstDiv.Contents:GetChildren())
					itemReplica.Display.Parent =
						firstDiv.Contents:FindFirstChild("Intelligence" .. intelligenceRequired).Frame

					table.insert(module.Crafts["intelligence" .. intelligenceRequired], {
						item = item,
						craftIndex = i,
					})
				end
			end
		end
	end

	for _, tab in firstDiv.Contents:GetChildren() do
		if not tab:IsA("Frame") then
			continue
		end
		tab.Visible = false
	end
end

function module.Start()
	local firstDiv = module.Display.Frame.Frame.First
	local secondDiv = module.Display.Frame.Frame.Second
	local tabSystem = createTabSystem(firstDiv.Tabs, firstDiv.Contents, function(tabName: string)
		print("Tab changed to: " .. tabName)
	end)
	tabSystem.toggleTabActive("Intelligence30")
end

function module.Stop()
	module.Trove:Destroy()
end

function module.Destroy()
	module.Trove:Destroy()
end

return module
