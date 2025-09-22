local module = {

	Name = script.Name:match("_ (.*)"),
	Id = tonumber(script.Name:match("^(.-) _")),
	Material = Enum.Material.CorrodedMetal,
	Health = 80,
	MaxHealth = 100,
}

return module
