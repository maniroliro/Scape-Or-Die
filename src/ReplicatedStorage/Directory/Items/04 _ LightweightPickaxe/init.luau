local module = {

	Name = script.Name:match("_ (.*)"),
	Id = tonumber(script.Name:match("^(.-) _")),
	Legal = false,
	MetalDetectorCanDetect = true,
	CanSpawnInChests = false,

	Health = 100,
	HealthDecreaseEachUse = 20,

	-- UseItem = function(self, ...)

	-- 	return true
	-- end,

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
			Name = "Medium",
		},
	},
}

return module
