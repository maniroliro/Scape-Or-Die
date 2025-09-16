--!strict
local RoundXRotation = require(script.Parent.GetLegalRotation)

return function(cf: CFrame): CFrame
	if typeof(cf) ~= "CFrame" then
		return (nil :: any) :: CFrame
	end
	local p = cf.Position
	local x = math.floor(p.X / 4) * 4 + 2
	local y = math.round(p.Y / 2) * 2
	local z = math.floor(p.Z / 4) * 4 + 2
	-- Se quiser manter a rotação original, troque para: cf.Rotation * CFrame.new(x, y, z)
	local newPos = CFrame.new(x, y, z)
	return newPos * RoundXRotation(cf.Rotation)
end
