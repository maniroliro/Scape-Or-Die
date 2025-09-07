export type Type = {
	Name: string,
	Id: number,
	Difficult: number, --1 --2 --3
}

local template = script:FindFirstChild("00 _ Template")
assert(template, "Template module not found in directory")
--export type Type = typeof(template)

local DirUtil = require(script.Parent:WaitForChild("Utils"):WaitForChild("Directory"))
return DirUtil.newDirectory(script) :: DirUtil.ClassType<typeof(template)>
