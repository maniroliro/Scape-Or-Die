--!strict
local RoundXRotation = require(script.Parent.GetLegalRotation)

return function(p: Vector3, strType: string): Vector3
	if typeof(p) ~= "Vector3" then
		return (nil :: any) :: Vector3
	end

	if strType == "x" then
		return Vector3.new(math.floor(p.X / 4) * 4 + 2, p.Y, p.Z)
	elseif strType == "y" then
		return Vector3.new(p.X, math.round(p.Y / 2) * 2, p.Z)
	elseif strType == "z" then
		return Vector3.new(p.X, p.Y, math.floor(p.Z / 4) * 4 + 2)
	elseif strType == "xyz" or not strType then
		local x = math.floor(p.X / 4) * 4 + 2
		local y = math.round(p.Y / 2) * 2
		local z = math.floor(p.Z / 4) * 4 + 2
		-- Se quiser manter a rotação original, troque para: cf.Rotation * CFrame.new(x, y, z)
		local newPos = Vector3.new(x, y, z)
		return newPos
	end

	return p
end
