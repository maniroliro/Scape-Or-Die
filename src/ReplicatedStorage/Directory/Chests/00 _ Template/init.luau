return {

	Name = script.Name:match("_ (.*)"),
	Id = tonumber(script.Name:match("^(.-) _")),
	CanSpawnItems = true,
	CanSpawnIlegalItems = true,
	MaxDistanceToInteract = 6,
	OpenTime = 4,
}
