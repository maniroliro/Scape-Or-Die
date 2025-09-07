local module = {
	
	Name = script.Name:match("| (.*)"), 
	Id = tonumber(script.Name:match("^(.-) |")),
	Legal = false,
	MetalDetectorCanDetect = true,
	CanSpawnInChests = true,
	
	AttackInfos = {
		Speed = {
			Value = 1,
			Name = 'Low'
		},
		Damage = {
			Value = 2,
			Name = 'Medium'
		},
		Range = {
			Value = 3,
			Name = 'High'
		}
	}
	
}

return module
