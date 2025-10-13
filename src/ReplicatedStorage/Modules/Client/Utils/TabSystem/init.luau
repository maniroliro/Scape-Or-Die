local trove = require(game:GetService("ReplicatedStorage").lib.lib.ModuleUtils._Trove)

local function createSystem(
	tabsFolder: Instance,
	contentsFolder: Instance,
	callback: Instance | (tabName: string) -> ()?
)
	local modulesRequired
	if callback then
		if typeof(callback) == "Instance" then
			modulesRequired = {}
			for _, moduleScript in callback:GetChildren() do
				if moduleScript:IsA("ModuleScript") then
					modulesRequired[moduleScript.Name] = require(moduleScript)
					if modulesRequired[moduleScript.Name].Init then
						modulesRequired[moduleScript.Name].Init()
					end
				end
			end
		elseif typeof(callback) == "function" then
			modulesRequired = nil
		else
			error("Invalid callback type. Expected Instance or function.")
		end
	end

	local function toggleTabActive(tabName: string)
		local content = contentsFolder:FindFirstChild(tabName)
		for _, otherTab in tabsFolder:GetChildren() do
			if not otherTab:IsA("Frame") then
				continue
			end
			if otherTab.Name == tabName then
				otherTab.Background.BackgroundColor3 = Color3.fromRGB(66, 79, 97)
				otherTab.Background.Transparency = 0
				otherTab.Background.ZIndex = 3
				otherTab.Frame.ZIndex = 1
				otherTab.Visible = true
				continue
			end
			otherTab.Background.BackgroundColor3 = Color3.fromRGB(139, 170, 202)
			otherTab.Background.Transparency = 0.5
			otherTab.Background.ZIndex = -1
			otherTab.Frame.ZIndex = -1

			if not contentsFolder:FindFirstChild(otherTab.Name) then
				print(contentsFolder:FindFirstChild(otherTab.Name))
				otherTab.Visible = false
			end
		end
		for _, otherContent in contentsFolder:GetChildren() do
			if not otherContent:IsA("Frame") then
				continue
			end
			if otherContent == content then
				otherContent.Visible = true
			else
				otherContent.Visible = false
			end
		end

		if modulesRequired then
			for name, module in modulesRequired do
				if name == tabName then
					if module.Start then
						module.Start()
					end
				else
					if module.Stop then
						module.Stop()
					end
				end
			end
		elseif typeof(callback) == "function" then
			callback(tabName)
		end
	end

	local newTrove = trove.new()
	for _, tab in tabsFolder:GetChildren() do
		if not tab:IsA("Frame") then
			continue
		end
		newTrove:Add(tab:FindFirstChildWhichIsA("GuiButton").Activated:Connect(function()
			toggleTabActive(tab.Name)
		end))
	end
	return {
		Trove = newTrove,
		toggleTabActive = toggleTabActive,
	}
end

return createSystem
