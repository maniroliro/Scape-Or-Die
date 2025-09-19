local module = {

	Name = script.Name:match("_ (.*)"),
	Id = tonumber(script.Name:match("^(.-) _")),
	Material = Enum.Material.Concrete,
	Health = 100,
	MaxHealth = 100,
}

return module
