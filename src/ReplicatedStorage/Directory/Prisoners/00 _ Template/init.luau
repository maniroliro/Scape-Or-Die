local module = {

	Name = script.Name:match("_ (.*)"),
	Id = tonumber(script.Name:match("^(.-) _")),

	Health = 100,
	MaxHealth = 100,
	Damage = 10,

	FOV = 70,

	MaxStamina = 100,
	Stamina = 100,

	Heat = 0,
	Intellect = 30,
	Money = 0,
}

return module
