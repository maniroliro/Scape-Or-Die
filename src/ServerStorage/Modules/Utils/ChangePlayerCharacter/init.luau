local replicatedStorage = game:GetService("ReplicatedStorage")

local Assets = replicatedStorage.Assets
local rigsFolder = Assets.Rigs
local prisionerRig = rigsFolder.Prisoner

return function(player: Player, rig: Model?)
	local char = player.Character --or player.CharacterAdded:Wait()
	assert(char, "Character not found")

	rig = rig or prisionerRig
	local newChar = (rig :: Model):Clone()

	newChar.PrimaryPart = newChar.HumanoidRootPart
	newChar:SetPrimaryPartCFrame(char.PrimaryPart.CFrame)
	newChar.Name = player.Name
	if char:FindFirstChild("Animate") and not newChar:FindFirstChild("Animate") then
		char.Animate:Clone().Parent = newChar
	end
	if char:FindFirstChild("Health") and not newChar:FindFirstChild("Health") then
		char.Health:Clone().Parent = newChar
	end
	player.Character = newChar
	newChar.Parent = game.Workspace
	newChar:FindFirstChild("HumanoidRootPart").CFrame = char.HumanoidRootPart.CFrame
	for _, part in pairs(newChar:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
		end
	end
end
