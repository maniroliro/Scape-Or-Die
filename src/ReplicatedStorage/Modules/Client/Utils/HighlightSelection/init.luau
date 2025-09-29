local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local localPlayer = game:GetService("Players").LocalPlayer

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local trove = lib.ModuleUtils.Trove
local signal = lib.ModuleUtils.Signal

local mouse = localPlayer:GetMouse()
mouse.TargetFilter = localPlayer.Character or localPlayer.CharacterAdded:Wait()

local highlight = Instance.new("Highlight")
highlight.Enabled = false
highlight.Adornee = nil
highlight.DepthMode = Enum.HighlightDepthMode.Occluded
highlight.Parent = localPlayer
highlight.FillColor = Color3.fromRGB(255, 255, 255)
highlight.FillTransparency = 1 -- 0.9
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.OutlineTransparency = 0

local module = {}
module.selections = {}
module.trove = trove.new()
module.selectableTotalChanged = signal.new()
module.totalSelectables = 0
module.highlight = highlight

local function fireTotalSelected(plusOrMinus: string)
	if not t.string(plusOrMinus) then
		return
	end
	if plusOrMinus ~= "+" and plusOrMinus ~= "-" then
		return
	end
	if plusOrMinus == "+" then
		module.totalSelectables = module.totalSelectables + 1
	elseif plusOrMinus == "-" then
		module.totalSelectables = module.totalSelectables - 1
	end

	module.selectableTotalChanged:Fire(module.totalSelectables)
end

function module.addSelection(part: PVInstance, maxDistance: number?)
	if module.selections[part] then
		return nil
	end
	module.selections[part] = {
		highlight = nil,
		hovering = false,
		maxDistance = maxDistance or 20,
	}

	fireTotalSelected("+")
	return module.selections[part]
end

function module.removeSelection(part: PVInstance)
	if not module.selections[part] then
		return nil
	end

	local highlightPart = module.selections[part].highlight
	if highlightPart then
		highlightPart:Destroy()
	end
	module.selections[part].highlight = nil
	module.selections[part] = nil

	fireTotalSelected("-")
	return nil
end

function module.clearSelections()
	module.selections = {}
end

return module
