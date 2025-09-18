--!strict
local getLegalRotation = require(script.Parent.GetLegalRotation)
local getLegalPosition = require(script.Parent.GetLegalPosition)

return function(cf: CFrame): CFrame
	if typeof(cf) ~= "CFrame" then
		return (nil :: any) :: CFrame
	end
	return CFrame.new(getLegalPosition(cf.Position)) * getLegalRotation(cf.Rotation)
end
