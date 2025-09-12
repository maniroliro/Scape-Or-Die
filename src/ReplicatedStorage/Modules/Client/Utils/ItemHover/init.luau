local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local assetsFolder = ReplicatedStorage:WaitForChild("Assets")
local itemInfoOverlay = assetsFolder:WaitForChild("Displays"):WaitForChild("ItemInfoOverlay"):Clone()

local lib = require(ReplicatedStorage:WaitForChild("lib"))
local trove = lib.ModuleUtils.Trove

local LocalPlayer = game.Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local OffsetX, OffsetY = 50, 10
local Padding = 60
local itemHovering
local IsHovering = false

local DeviceWidthSettings = {
	Mobile = {
		WidthPercentage = 0.30,
		MinWidth = 65,
		MaxWidth = 100,
	},
	Tablet = {
		WidthPercentage = 0.25,
		MinWidth = 150,
		MaxWidth = 200,
	},
	Desktop = {
		WidthPercentage = 0.20,
		MinWidth = 150,
		MaxWidth = 200,
	},
}

local VerticalPadding = 0.01 -- 1% of screen height for top/bottom padding
local LabelSpacing = 0.005 -- 0.5% of screen height between labels

type LabelValue = string | {
	Text: string?,
	Color: Color3?,
	Gradient: UIGradient?,
}

local function GetScreenSize()
	local Camera = workspace.CurrentCamera
	return Camera.ViewportSize
end

local function GetDeviceType()
	local UserInputService = game:GetService("UserInputService")
	local ScreenSize = GetScreenSize()

	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		local AspectRatio = ScreenSize.X / ScreenSize.Y
		local MinDimension = math.min(ScreenSize.X, ScreenSize.Y)
		local MaxDimension = math.max(ScreenSize.X, ScreenSize.Y)
		local ScreenArea = ScreenSize.X * ScreenSize.Y

		-- More refined tablet detection
		if
			(MinDimension > 700)
			or (ScreenArea > 800000 and AspectRatio > 1.2 and AspectRatio < 1.8)
			or (MinDimension > 600 and MaxDimension > 900)
		then
			return "Tablet"
		else
			return "Mobile"
		end
	else
		return "Desktop"
	end
end

local function GetDeviceSettings()
	local DeviceType = GetDeviceType()
	return DeviceWidthSettings[DeviceType]
end

local function ApplyValue(label: TextLabel, value)
	if typeof(value) == "table" then
		label.Text = value.Text or ""

		if value.Gradient and typeof(value.Gradient) == "Instance" and value.Gradient:IsA("UIGradient") then
			for _, v in label:GetChildren() do
				if v:IsA("UIGradient") then
					v:Destroy()
				end
			end

			local GradientClone = value.Gradient:Clone()
			GradientClone.Parent = label
		elseif value.Color then
			label.TextColor3 = value.Color
		end
	else
		label.Text = tostring(value)
	end
end

local function SizeLabel(label: TextLabel, heightPercentage: number, yPosition: number, frameWidth: number)
	local ScreenSize = GetScreenSize()
	local LabelHeight = ScreenSize.Y * heightPercentage

	label.Size = UDim2.new(0, frameWidth - 20, 0, LabelHeight)
	label.Position = UDim2.new(0, 10, 0, yPosition)
end

local function CalculateFrameSize(labelCount: number)
	local ScreenSize = GetScreenSize()
	local DeviceSettings = GetDeviceSettings()

	local TotalHeight = 0
	TotalHeight = TotalHeight + (ScreenSize.Y * VerticalPadding * 2)

	if labelCount > 1 then
		TotalHeight = TotalHeight + (ScreenSize.Y * LabelSpacing * (labelCount - 1))
	end

	local CalculatedWidth = ScreenSize.X * DeviceSettings.WidthPercentage
	local FrameWidth = math.max(DeviceSettings.MinWidth, math.min(DeviceSettings.MaxWidth, CalculatedWidth))

	return FrameWidth, TotalHeight
end

local function ItemInfoOrganizer(item)
	if not item then
		return
	end

	itemInfoOverlay.UIStroke.Color = item.Legal and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 0, 4)
	itemInfoOverlay.Info.ItemName.Text = item.UID

	local infoinfo = itemInfoOverlay.Info.Info
	infoinfo.Speed.Text = "Speed: " .. item.AttackInfos.Speed.Name
	infoinfo.Damage.Text = "Damage: " .. item.AttackInfos.Damage.Name
	infoinfo.Range.Text = "Range: " .. item.AttackInfos.Range.Name
end

local module = {}
module.trove = trove.new()
module.itemsBeingObserved = {}

itemInfoOverlay.Parent = LocalPlayer.PlayerGui:WaitForChild("OverlayGui")

local function UpdatePosition()
	local ScreenSize = workspace.CurrentCamera.ViewportSize
	local FrameSize = itemInfoOverlay.AbsoluteSize

	local PositionX = math.clamp(Mouse.X + 90, Padding, ScreenSize.X - FrameSize.X - Padding)
	local PositionY =
		math.clamp(Mouse.Y + FrameSize.Y + FrameSize.Y / 3 + 5, Padding, ScreenSize.Y - FrameSize.Y - Padding)
	itemInfoOverlay.Position = UDim2.fromOffset(PositionX, PositionY)
end

module.trove:Add(RunService.PreRender:Connect(function()
	if IsHovering then
		UpdatePosition()
		itemInfoOverlay.Visible = true
	else
		itemInfoOverlay.Visible = false
	end
end))

function module.addItem(item)
	if not item.Display or not item.Display:IsA("Frame") and not module.itemsBeingObserved[item.UID] then
		return
	end
	module.itemsBeingObserved[item.UID] = {}

	local con
	local con2
	con = item.Display.MouseEnter:Connect(function()
		itemHovering = item.UID
		IsHovering = true
		ItemInfoOrganizer(item)
		UpdatePosition()
	end)

	con2 = item.Display.MouseLeave:Connect(function()
		if itemHovering == item.UID then
			IsHovering = false
		end
	end)

	module.itemsBeingObserved[item.UID] = { con, con2 }
	module.trove:Add(con)
	module.trove:Add(con2)
end

function module.removeItem(itemUID: string)
	if not module.itemsBeingObserved[itemUID] then
		return
	end

	for k, v in module.itemsBeingObserved[itemUID] do
		v:Disconnect()
		module.itemsBeingObserved[itemUID][k] = nil
	end

	module.itemsBeingObserved[itemUID] = nil
end

return module
