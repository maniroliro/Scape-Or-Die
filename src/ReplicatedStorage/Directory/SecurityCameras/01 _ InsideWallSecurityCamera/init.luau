return {

	Name = script.Name:match("_ (.*)"),
	Id = tonumber(script.Name:match("^(.-) _")),
	RotationDelay = 2,
	RotationAngle = 15,
	RotationToEachSide = 2,
	FOV = 90,
	ViewMaxDistance = 40,
}
