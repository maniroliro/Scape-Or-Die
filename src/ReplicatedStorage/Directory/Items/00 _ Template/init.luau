local module = {

	Name = script.Name:match("_ (.*)"),
	Id = tonumber(script.Name:match("^(.-) _")),
	Legal = false,
	MetalDetectorCanDetect = true,
	CanSpawnInChests = true,

	Crafts = {
		{
			item1 = 0,
			item2 = 0,
			item3 = 0,
			intelligenceRequired = 30,
		},
	},

	AttackInfos = {
		Speed = {
			Value = 1,
			Name = "Low",
		},
		Damage = {
			Value = 2,
			Name = "Medium",
		},
		Range = {
			Value = 3,
			Name = "High",
		},
	},
}

return module
