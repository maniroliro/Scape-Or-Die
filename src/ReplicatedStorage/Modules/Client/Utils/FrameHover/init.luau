local replicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local lib = require(replicatedStorage:WaitForChild("lib"))
local trove = lib.ModuleUtils.Trove

local LocalPlayer = game.Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--local OffsetX, OffsetY = 50, 10
local Padding = 60

-- local DeviceWidthSettings = {
-- 	Mobile = {
-- 		WidthPercentage = 0.30,
-- 		MinWidth = 65,
-- 		MaxWidth = 100,
-- 	},
-- 	Tablet = {
-- 		WidthPercentage = 0.25,
-- 		MinWidth = 150,
-- 		MaxWidth = 200,
-- 	},
-- 	Desktop = {
-- 		WidthPercentage = 0.20,
-- 		MinWidth = 150,
-- 		MaxWidth = 200,
-- 	},
-- }

-- local VerticalPadding = 0.01 -- 1% of screen height for top/bottom padding
-- local LabelSpacing = 0.005 -- 0.5% of screen height between labels

-- type LabelValue = string | {
-- 	Text: string?,
-- 	Color: Color3?,
-- 	Gradient: UIGradient?,
-- }

-- local function GetScreenSize()
-- 	local Camera = workspace.CurrentCamera
-- 	return Camera.ViewportSize
-- end

-- local function GetDeviceType()
-- 	local UserInputService = game:GetService("UserInputService")
-- 	local ScreenSize = GetScreenSize()

-- 	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
-- 		local AspectRatio = ScreenSize.X / ScreenSize.Y
-- 		local MinDimension = math.min(ScreenSize.X, ScreenSize.Y)
-- 		local MaxDimension = math.max(ScreenSize.X, ScreenSize.Y)
-- 		local ScreenArea = ScreenSize.X * ScreenSize.Y

-- 		-- More refined tablet detection
-- 		if
-- 			(MinDimension > 700)
-- 			or (ScreenArea > 800000 and AspectRatio > 1.2 and AspectRatio < 1.8)
-- 			or (MinDimension > 600 and MaxDimension > 900)
-- 		then
-- 			return "Tablet"
-- 		else
-- 			return "Mobile"
-- 		end
-- 	else
-- 		return "Desktop"
-- 	end
-- end

-- local function GetDeviceSettings()
-- 	local DeviceType = GetDeviceType()
-- 	return DeviceWidthSettings[DeviceType]
-- end

-- local function ApplyValue(label: TextLabel, value)
-- 	if typeof(value) == "table" then
-- 		label.Text = value.Text or ""

-- 		if value.Gradient and typeof(value.Gradient) == "Instance" and value.Gradient:IsA("UIGradient") then
-- 			for _, v in label:GetChildren() do
-- 				if v:IsA("UIGradient") then
-- 					v:Destroy()
-- 				end
-- 			end

-- 			local GradientClone = value.Gradient:Clone()
-- 			GradientClone.Parent = label
-- 		elseif value.Color then
-- 			label.TextColor3 = value.Color
-- 		end
-- 	else
-- 		label.Text = tostring(value)
-- 	end
-- end

-- local function SizeLabel(label: TextLabel, heightPercentage: number, yPosition: number, frameWidth: number)
-- 	local ScreenSize = GetScreenSize()
-- 	local LabelHeight = ScreenSize.Y * heightPercentage

-- 	label.Size = UDim2.new(0, frameWidth - 20, 0, LabelHeight)
-- 	label.Position = UDim2.new(0, 10, 0, yPosition)
-- end

-- local function CalculateFrameSize(labelCount: number)
-- 	local ScreenSize = GetScreenSize()
-- 	local DeviceSettings = GetDeviceSettings()

-- 	local TotalHeight = 0
-- 	TotalHeight = TotalHeight + (ScreenSize.Y * VerticalPadding * 2)

-- 	if labelCount > 1 then
-- 		TotalHeight = TotalHeight + (ScreenSize.Y * LabelSpacing * (labelCount - 1))
-- 	end

-- 	local CalculatedWidth = ScreenSize.X * DeviceSettings.WidthPercentage
-- 	local FrameWidth = math.max(DeviceSettings.MinWidth, math.min(DeviceSettings.MaxWidth, CalculatedWidth))

-- 	return FrameWidth, TotalHeight
-- end

local module = {}

module.trove = trove.new()
module.ItemsBeingObserved = {}

export type ClassType<frameTemplate = Frame, infos = { [string]: any }> = typeof(setmetatable(
	{} :: {
		Trove: lib.TroveType,
		ItemsBeingObserved: { [infos | any]: { RBXScriptConnection } },
		Display: frameTemplate & Frame,
		OrganizationFunction: (self: ClassType<frameTemplate, infos>, itemPassed: infos | any) -> (),
		DesorganizationFunction: (self: ClassType<frameTemplate, infos>, itemPassed: infos | any) -> (),
		ItemHovering: infos | any,
	},
	{ __index = module }
))

local function UpdatePosition(display: Frame)
	local ScreenSize = workspace.CurrentCamera.ViewportSize
	local FrameSize = display.AbsoluteSize

	local PositionX = math.clamp(Mouse.X + 90, Padding, ScreenSize.X - FrameSize.X - Padding)
	local PositionY =
		math.clamp(Mouse.Y + FrameSize.Y + FrameSize.Y / 3 + 5, Padding, ScreenSize.Y - FrameSize.Y - Padding)
	display.Position = UDim2.fromOffset(PositionX, PositionY)
end

function module.addItem<frameTemplate, infos>(self: ClassType<frameTemplate, infos>, info: infos & any)
	if not info.Display or not info.Display:IsA("Frame") and not self.ItemsBeingObserved[info.UID] then
		return
	end
	self.ItemsBeingObserved[info] = {}

	local con
	local con2
	con = info.Display.MouseEnter:Connect(function()
		self.ItemHovering = info
		if self.OrganizationFunction then
			self:OrganizationFunction(info)
		end
		UpdatePosition(self.Display)
	end)

	con2 = info.Display.MouseLeave:Connect(function()
		if self.ItemHovering == info then
			self:forceHide(info)
		end
	end)

	self.ItemsBeingObserved[info] = { con, con2 }
	self.Trove:Add(con)
	self.Trove:Add(con2)
end

function module.removeItem<frameTemplate, infos>(self: ClassType<frameTemplate, infos>, info: any)
	if not self.ItemsBeingObserved[info] then
		return
	end

	self:forceHide(info)

	for k, v in self.ItemsBeingObserved[info] do
		v:Disconnect()
		self.ItemsBeingObserved[info][k] = nil
	end

	self.ItemsBeingObserved[info] = nil

	return self
end

function module.forceHide<frameTemplate, infos>(self: ClassType<frameTemplate, infos>, info: infos?)
	if self.ItemHovering ~= info then
		return false
	end

	if self.DesorganizationFunction then
		self:DesorganizationFunction(info)
	end
	self.ItemHovering = nil
	self.Display.Visible = false

	return self
end

function module.newHover<frameTemplate, infos>(
	frameTemplate: frameTemplate & Frame,
	organizationFunction: (self: ClassType<frameTemplate, infos>, itemPassed: infos) -> (),
	desorganizationFunction: ((self: ClassType<frameTemplate, infos>, itemPassed: infos) -> ())?
): ClassType<frameTemplate, infos>
	local self = setmetatable({}, { __index = module }) :: ClassType<frameTemplate, infos>
	self.Trove = trove.new()
	self.Display = frameTemplate:Clone() :: frameTemplate
	self.OrganizationFunction = organizationFunction
	self.DesorganizationFunction = desorganizationFunction or function() end
	self.ItemsBeingObserved = {}
	self.ItemHovering = nil

	self.Display.Visible = false
	self.Display.Parent = LocalPlayer.PlayerGui:WaitForChild("OverlayGui")

	self.Trove:Add(RunService.PreRender:Connect(function()
		if self.ItemHovering then
			UpdatePosition(self.Display)
			self.Display.Visible = true
		else
			self.Display.Visible = false
		end
	end))

	return self
end

return module
