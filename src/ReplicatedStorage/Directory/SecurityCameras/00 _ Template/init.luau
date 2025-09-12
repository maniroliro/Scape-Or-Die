return {

	Name = script.Name:match("_ (.*)"),
	Id = tonumber(script.Name:match("^(.-) _")),
	RotationDelay = 2,
	RotationAngle = 15,
	Fov = 60,
	MaxDistance = 40,
}
