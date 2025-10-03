local replicatedStorage = game:GetService("ReplicatedStorage")
local wall = workspace.walltobreak

local lib = require(replicatedStorage.lib)
local FunctionUtils = lib.FunctionUtils
local utils = lib.Utils
local charUtil = FunctionUtils.Character
local getLegalRotation = utils.GetLegalRotation

-- Snappa a rotação inteira (X, Y, Z) para múltiplos de 90°

local deb = 0.2
local ok = true
local function cut(partPassed: Part)
	local con
	con = partPassed.Touched:Connect(function(who)
		local char = charUtil.getCharacterFromDescendant(who)

		if char then
			if not ok then
				return
			end
			ok = false

			con:Disconnect()
			local charCF = char.PrimaryPart.CFrame
			local part = Instance.new("Part")
			part.Size = Vector3.new(4, 8, 2)
			part.Anchored = true
			part.Transparency = 0.9
			part.CanCollide = false
			part.CanTouch = false

			local cf = getLegalRotation(charCF.Rotation)
			cf = cf + charCF.Position + charCF.LookVector.Unit * 1

			part.CFrame = cf

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
