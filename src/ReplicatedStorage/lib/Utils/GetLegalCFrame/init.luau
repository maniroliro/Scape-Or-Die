--!strict
return function(cf: CFrame): CFrame
	local p = cf.Position
	local x = math.floor(p.X / 4) * 4 + 2
	local y = math.round(p.Y / 2) * 2
	local z = math.floor(p.Z / 4) * 4 + 2
	-- Se quiser manter a rotação original, troque para: cf.Rotation * CFrame.new(x, y, z)
	return CFrame.new(x, y, z) * cf.Rotation
end
