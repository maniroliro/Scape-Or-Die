local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local lib = require(replicatedStorage:WaitForChild("lib"))
local libUtils = lib.ModuleUtils
local trove = libUtils.Trove

local highlightSelectionUtil = require(replicatedStorage.Modules.Client.Utils.HighlightSelection)

local module = {}
module.trove = trove.new()
module.checkConnection = nil

local tweenInfo1 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function module.Init() end

function module.Start()
	highlightSelectionUtil.selectableTotalChanged:Connect(function(total)
		if total > 0 and not module.checkConnection then
			local db = 0
			module.checkConnection = runService.RenderStepped:Connect(function(dt)
				db = db + dt
				if db <= 0.025 then
					return
				end
				db = 0

				local target = mouse.Target
				local partInfo = highlightSelectionUtil.selections[target]
				if not partInfo then
					target = target and target:FindFirstAncestorOfClass("Model")
					partInfo = highlightSelectionUtil.selections[target]
				end
				if target and partInfo then
					if not partInfo.hovering then
						userInputService.MouseIcon = "rbxasset://SystemCursors/PointingHand"
						partInfo.hovering = true
						if not partInfo.highlight then
							partInfo.highlight = highlightSelectionUtil.highlight:Clone()
							partInfo.highlight.Parent = player
							partInfo.highlight.Adornee = target
						end
						partInfo.highlight.Enabled = true

						tweenService
							:Create(partInfo.highlight, tweenInfo1, {
								FillTransparency = 0.9,
								OutlineTransparency = 0,
							})
							:Play()
					end
				else
					userInputService.MouseIcon = "rbxasset://SystemCursors/Arrow"
				end
				for _, v in highlightSelectionUtil.selections do
					if v == partInfo then
						continue
					end
					if v.hovering then
						v.hovering = false

						local tw = tweenService:Create(v.highlight, tweenInfo1, {
							FillTransparency = 1,
							OutlineTransparency = 1,
						})
						tw:Play()
						task.spawn(function()
							tw.Completed:Wait()
							v.highlight.Enabled = false
							v.highlight:Destroy()
							v.highlight = nil
						end)
					end
				end
			end)
		elseif total <= 0 and module.checkConnection then
			module.checkConnection:Disconnect()
			module.checkConnection = nil
			userInputService.MouseIcon = "rbxasset://SystemCursors/Arrow"
		end
	end)
end

return module
