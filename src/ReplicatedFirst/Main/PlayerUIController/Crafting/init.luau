local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local playerGUI = player:WaitForChild("PlayerGui") :: PlayerGui

local lib = require(replicatedStorage.lib)
local trove = lib.ModuleUtils.Trove

local clientModules = replicatedStorage.Modules.Client

local createTabSystem = require(script.Parent.Utils.TabSystem)

local itemDirectory = replicatedStorage.Directory.Items
local itemReplicaModule = require(replicatedStorage.Modules.Client.Replicas.ItemReplica)

local assetsFolder = replicatedStorage:WaitForChild("Assets")
local craftInfoOverlay = assetsFolder:WaitForChild("Displays"):WaitForChild("CraftItemInfoOverlay")

local frameHover = require(clientModules.Utils.FrameHover)

type craftInfo = {
	itemToCraft1: itemReplicaModule.ClassType,
	itemToCraft2: itemReplicaModule.ClassType,
	itemToCraft3: itemReplicaModule.ClassType,
	resultItem: itemReplicaModule.ClassType,
	Display: Frame,
	intelligenceRequired: number,
}

type craftFrame = typeof(craftInfoOverlay)

local craftInfoHover: frameHover.ClassType<craftFrame, craftInfo> = frameHover.newHover(
	craftInfoOverlay,
	function(self, info: craftInfo)
		self.Display.Tittle.text.TextLabel.Text = info.resultItem.Name

		for i = 1, 3 do
			local displayNow = info["itemToCraft" .. i].Display
			local framebase = self.Display.Frame["Frame" .. i]
			displayNow.Parent = framebase
			displayNow.ZIndex += info.Display.ZIndex + 1

			for _, child in displayNow:GetDescendants() do
				if child:IsA("GuiObject") then
					child.ZIndex += info.Display.ZIndex + 1
				end
			end
		end
	end,
	function(self, info: craftInfo)
		for i = 1, 3 do
			info["itemToCraft" .. i].Display.Parent = nil
		end
	end
)

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
	local secondDiv = module.Display.Frame.Frame.Second

	for _, int in firstDiv.Contents:GetChildren() do
		if not int:IsA("Frame") then
			continue
		end
		if not int:FindFirstChild("Frame") then
			continue
		end
		local i = 1
		for _, frame in int:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			frame.Name = "Frame" .. i
			i += 1
		end
	end

	for _, itemModule in itemDirectory:GetChildren() do
		if itemModule:IsA("ModuleScript") then
			local item = require(itemModule)
			if item and item.Crafts and #item.Crafts > 0 then
				for i, craft: { item1: number, item2: number, item3: number, intelligenceRequired: number } in
					item.Crafts
				do
					local intelligenceRequired = craft.intelligenceRequired
					local itemReplica = itemReplicaModule.new()
					itemReplica:AttachId(item.Id)
					itemReplica:CreateDisplay()

					local frame = firstDiv.Contents
						:FindFirstChild("Intelligence" .. intelligenceRequired)
						:FindFirstChild("Frame" .. #module.Crafts["intelligence" .. intelligenceRequired] + 1)
					local itemDisplay = itemReplica.Display
					itemDisplay.Parent = frame

					itemDisplay.ZIndex += frame.ZIndex + 1
					for _, child in itemDisplay:GetDescendants() do
						if child:IsA("GuiObject") then
							child.ZIndex += frame.ZIndex + 1
						end
					end

					local itemToCraft1 = itemReplicaModule.new()
					itemToCraft1:AttachId(craft.item1)
					itemToCraft1:CreateDisplay()

					local itemToCraft2 = itemReplicaModule.new()
					itemToCraft2:AttachId(craft.item2)
					itemToCraft2:CreateDisplay()

					local itemToCraft3 = itemReplicaModule.new()
					itemToCraft3:AttachId(craft.item3)
					itemToCraft3:CreateDisplay()

					local craftInfo = {
						itemToCraft1 = itemToCraft1,
						itemToCraft2 = itemToCraft2,
						itemToCraft3 = itemToCraft3,
						resultItem = itemReplica,
						Display = itemReplica.Display,
						intelligenceRequired = intelligenceRequired,
					}

					craftInfoHover:addItem(craftInfo)

					frame.ImageButton.Activated:Connect(function()
						local frame = secondDiv.Frame.Frame.Frame

						for i = 1, 3 do
							local frameToParent = frame:FindFirstChild("Frame" .. i)
							local clone = craftInfo["itemToCraft" .. i].Display:Clone()
							clone.Name = "Clone"

							local cloneToDestroy = frameToParent:FindFirstChild("Clone")
							if cloneToDestroy then
								cloneToDestroy:Destroy()
							end

							clone.Parent = frameToParent
						end
					end)

					table.insert(module.Crafts["intelligence" .. intelligenceRequired], {
						item = itemReplica,
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
