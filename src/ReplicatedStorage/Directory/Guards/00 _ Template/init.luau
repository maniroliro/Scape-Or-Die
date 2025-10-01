local module = {

	Name = script.Name:match("_ (.*)"),
	Id = tonumber(script.Name:match("^(.-) _")),

	Health = 100,
	MaxHealth = 100,
	Damage = 20,

	FOV = 110,
	Range = 90,

	PatrolSpeed = 12,
	EmergencySpeed = 15,
}

return module
