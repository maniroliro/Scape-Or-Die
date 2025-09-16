local replicatedStorage = game:GetService("ReplicatedStorage")
local wall = workspace.walltobreak
local wallPos = wall.Position

local lib = require(replicatedStorage.lib)
local FunctionUtils = lib.FunctionUtils
local utils = lib.Utils
local charUtil = FunctionUtils.Character
local getLegalRotation = utils.GetLegalRotation

-- Snappa a rotação inteira (X, Y, Z) para múltiplos de 90°

local deb = 0.2
local ok = true
local function cut(partPassed: Part)
	partPassed.Touched:Connect(function(who)
		if not ok then
			return
		end
		ok = false

		local char = charUtil.getCharacterFromDescendant(who)

		if char then
			local charPos = char.PrimaryPart.Position
			local part = Instance.new("Part")
			part.Size = Vector3.new(4, 8, 2)
			part.Anchored = true
			part.Transparency = 0.9
			part.CanCollide = false
			part.CanTouch = false

			local diff = (charPos - wallPos)

			local cf = getLegalRotation(char.PrimaryPart.CFrame.Rotation)
			cf = cf + char.PrimaryPart.Position + char.PrimaryPart.CFrame.LookVector.Unit * 1

			part.CFrame = cf
			--part.Parent = workspace

			--print(part)

			local newP = partPassed:SubtractAsync({ part })
			newP.Parent = workspace
			partPassed.Parent = nil
			partPassed:Destroy()
			cut(newP)
		end

		task.delay(deb, function()
			ok = true
		end)
	end)
end

cut(wall)
