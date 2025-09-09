local template = script:FindFirstChild("00 _ Template")
local templateInfo = require(template)

export type Type = typeof(templateInfo)

local DirUtil = require(script.Parent:WaitForChild("Utils"):WaitForChild("Directory"))
return DirUtil.newDirectory(script) :: DirUtil.ClassType<typeof(template)>
