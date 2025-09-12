local module = {

	Name = script.Name:match("_ (.*)"),
	Id = tonumber(script.Name:match("^(.-) _")),
	Legal = true,
	MetalDetectorCanDetect = true,
	CanSpawnInChests = true,

	AttackInfos = {
		Speed = {
			Value = 0,
			Name = "-",
		},
		Damage = {
			Value = 0,
			Name = "-",
		},
		Range = {
			Value = 0,
			Name = "-",
		},
	},
}

return module
