--!strict
local RoundXRotation = require(script.Parent.GetLegalRotation)

return function(cf: CFrame | Vector3, strType: string): CFrame
	if typeof(cf) ~= "CFrame" and typeof(cf) ~= "Vector3" then
		return (nil :: any) :: CFrame
	end

	if strType == "x" then
		return CFrame.new(math.floor(cf.X / 4) * 4 + 2, cf.Y, cf.Z)
	elseif strType == "y" then
		return CFrame.new(cf.X, math.round(cf.Y / 2) * 2, cf.Z)
	elseif strType == "z" then
		return CFrame.new(cf.X, cf.Y, math.floor(cf.Z / 4) * 4 + 2)
	elseif strType == "xyz" then
		local p = cf.Position
		local x = math.floor(p.X / 4) * 4 + 2
		local y = math.round(p.Y / 2) * 2
		local z = math.floor(p.Z / 4) * 4 + 2
		-- Se quiser manter a rotação original, troque para: cf.Rotation * CFrame.new(x, y, z)
		local newPos = CFrame.new(x, y, z)
		return newPos * RoundXRotation(cf.Rotation)
	end

	return CFrame.new(cf)
end
