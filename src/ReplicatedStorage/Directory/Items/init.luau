export type AttackInfoPreset = {
	Value: number,
	Name: string,
}

local template = script:FindFirstChild("00 _ Template")
assert(template, "Template module not found in directory")
export type Type = typeof(template)

local DirUtil = require(script.Parent:WaitForChild("Utils"):WaitForChild("Directory"))
return DirUtil.newDirectory(script) :: DirUtil.ClassType<typeof(template)>
