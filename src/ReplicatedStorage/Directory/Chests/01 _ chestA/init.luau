return {
	
	Name = script.Name:match("| (.*)"), 
	Id = tonumber(script.Name:match("^(.-) |")),
	CanSpawnItems = true,
	CanSpawnIlegalItems = true,
	MaxDistanceToInteract = 8,
	OpenTime = 1,
	
}