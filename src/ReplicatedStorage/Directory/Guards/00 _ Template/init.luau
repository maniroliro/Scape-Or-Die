local module = {

	Name = script.Name:match("_ (.*)"),
	Id = tonumber(script.Name:match("^(.-) _")),

	Health = 100,
	MaxHealth = 100,
	Damage = 30,
}

return module
