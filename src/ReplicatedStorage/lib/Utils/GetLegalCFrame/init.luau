--!strict

function a(cf: CFrame): CFrame
	local p = cf.Position
	local x = math.floor(p.X/4)*4 + 2
	local y = math.round(p.Y/2)*2
	local z = math.floor(p.Z/4)*4 + 2
	-- Se quiser manter a rotação original, troque para: cf.Rotation * CFrame.new(x, y, z)
	return CFrame.new(x, y, z) * cf.Rotation
end

local a1 = a(workspace.bau3.CFrame)
local a2 = a(a1)
print(a1)
print(a2)

return function(cf: CFrame): CFrame
	local p = cf.Position
	local x = math.floor(p.X/4)*4 + 2
	local y = math.round(p.Y/2)*2
	local z = math.floor(p.Z/4)*4 + 2
	-- Se quiser manter a rotação original, troque para: cf.Rotation * CFrame.new(x, y, z)
	return CFrame.new(x, y, z) * cf.Rotation
end
