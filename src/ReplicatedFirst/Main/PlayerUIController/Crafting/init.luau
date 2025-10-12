local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local playerGUI = player:WaitForChild("PlayerGui") :: PlayerGui

local lib = require(replicatedStorage.lib)
local trove = lib.ModuleUtils.Trove
local remotes = lib.Remotes

local clientModules = replicatedStorage.Modules.Client

local createTabSystem = require(script.Parent.Utils.TabSystem)

local itemDirectory = replicatedStorage.Directory.Items
local itemReplicaModule = require(replicatedStorage.Modules.Client.Replicas.ItemReplica)

local assetsFolder = replicatedStorage:WaitForChild("Assets")
local craftInfoOverlay = assetsFolder:WaitForChild("Displays"):WaitForChild("CraftItemInfoOverlay")
local craftUtil = require(replicatedStorage.Modules.Shared.Functions.CraftItem)

local frameHover = require(clientModules.Utils.FrameHover)

type craftInfo = {
	itemToCraft1: itemReplicaModule.ClassType,
	itemToCraft2: itemReplicaModule.ClassType,
	itemToCraft3: itemReplicaModule.ClassType,
	resultItem: itemReplicaModule.ClassType,
	Display: Frame,
	intelligenceRequired: number,
	Trove: lib.TroveType,
	craftIndex: number,
}

type craftFrame = typeof(craftInfoOverlay)

local module = {}
module.Display = playerGUI:WaitForChild("Menu").Frame.Menu.Frame.Contents.Crafting
module.Trove = trove.new()
module.ActivatedToCraft = nil

module.Crafts = {
	intelligence30 = {},
	intelligence40 = {},
	intelligence50 = {},
	intelligence60 = {},
	intelligence70 = {},
}

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

	local itemsFolderSorted = itemDirectory:GetChildren()
	table.sort(itemsFolderSorted, function(a, b)
		return a.Name < b.Name
	end)

	for _, itemModule in itemsFolderSorted do
		if itemModule:IsA("ModuleScript") then
			local item = require(itemModule)
			if item and item.Crafts and #item.Crafts > 0 then
				for i, craft: { item1: number, item2: number, item3: number, intelligenceRequired: number } in
					item.Crafts
				do
					local objtrove = trove.new()
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
						itemToCraft1 = objtrove:Add(itemToCraft1),
						itemToCraft2 = objtrove:Add(itemToCraft2),
						itemToCraft3 = objtrove:Add(itemToCraft3),
						resultItem = objtrove:Add(itemReplica),
						Display = objtrove:Add(itemReplica.Display),
						intelligenceRequired = intelligenceRequired,
						craftIndex = i,
						Trove = trove.new(),
					}

					craftInfoHover:addItem(craftInfo)

					local con = frame.ImageButton.Activated:Connect(function()
						print(frame.ImageButton)
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
							module.ActivatedToCraft = craftInfo
						end
					end)

					objtrove:Add(con)
					table.insert(module.Crafts["intelligence" .. intelligenceRequired], {
						Trove = objtrove,
						craftInfo = craftInfo,
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
	module.Trove:Add(secondDiv.Frame.Frame.Craft.ImageButton.Activated:Connect(function()
		print(
			"Crafting item:",
			module.ActivatedToCraft.resultItem.Id,
			"Craft Index:",
			module.ActivatedToCraft.craftIndex
		)
		local success =
			craftUtil.canCraftItem(player, module.ActivatedToCraft.resultItem.Id, module.ActivatedToCraft.craftIndex)
		print(success)
		if success then
			remotes.CraftItem:Fire(module.ActivatedToCraft.resultItem.Id, module.ActivatedToCraft.craftIndex)
		end
	end))
end

function module.Stop()
	module.Trove:Destroy()
end

function module.Destroy()
	module.Trove:Destroy()
end

return module
