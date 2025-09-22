local module = {

	Name = script.Name:match("_ (.*)"),
	Id = tonumber(script.Name:match("^(.-) _")),
	Material = Enum.Material.Concrete,
	Health = 150,
	MaxHealth = 150,
}

return module
