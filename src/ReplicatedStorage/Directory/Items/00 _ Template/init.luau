local module = {

	Name = script.Name:match("_ (.*)"),
	Id = tonumber(script.Name:match("^(.-) _")),
	Legal = true,
	MetalDetectorCanDetect = true,
	CanSpawnInChests = true,

	Usage = 100,
	MaxUsage = 100,
	UsageDecreaseEachUse = 20,

	ItemFunction = {
		1,
	},

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
			Name = "High",
		},
	},
}

return module
