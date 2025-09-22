local module = {

	Name = script.Name:match("_ (.*)"),
	Id = tonumber(script.Name:match("^(.-) _")),
	Material = Enum.Material.Asphalt,
	Health = 80,
	MaxHealth = 80,
}

return module
