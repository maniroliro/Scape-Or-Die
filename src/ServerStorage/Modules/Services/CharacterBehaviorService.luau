local replicatedStorage = game:GetService("ReplicatedStorage")

local lib = require(replicatedStorage.lib)
local remotes = lib.Remotes
local playerLoaded = lib.Remotes.PlayerLoaded

local Assets = replicatedStorage.Assets
local rigsFolder = Assets.Rigs
local prisionerRig = rigsFolder.Prisoner


local module = {}

function module.Init()
	
	
	
end

function module.Start()
	playerLoaded.OnServerEvent:Connect(function(player)
		if prisionerRig then
			local newChar = prisionerRig:Clone()
			newChar.PrimaryPart = newChar.HumanoidRootPart
			newChar:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
			newChar.Name = player.Name
			if player.Character:FindFirstChild("Animate") and not newChar:FindFirstChild("Animate") then
				player.Character.Animate:Clone().Parent = newChar
			end
			if player.Character:FindFirstChild("Health") and not newChar:FindFirstChild("Health") then
				player.Character.Health:Clone().Parent = newChar
			end
			player.Character = newChar
			newChar.Parent = game.Workspace
			newChar:FindFirstChild("HumanoidRootPart").CFrame = player.Character.HumanoidRootPart.CFrame
			for _, part in pairs(newChar:GetDescendants()) do
				if part:IsA("BasePart") then part.Anchored = false end
			end
		end
	end)
end




return module
