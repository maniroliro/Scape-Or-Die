--!strict
local roundAngle90 = function(n)
	return math.rad(math.round(math.deg(n) / 90) * 90)
end

return function(cf: CFrame): CFrame
	if typeof(cf) ~= "CFrame" then
		return (nil :: any) :: CFrame
	end
	local x, y, z = cf:ToEulerAnglesXYZ()
	local roundedX = roundAngle90(x)
	--local roundedY = roundAngle90(y)
	local roundedZ = roundAngle90(z)
	return CFrame.new(cf.Position) * CFrame.fromEulerAnglesXYZ(roundedX, y, roundedZ)
end
