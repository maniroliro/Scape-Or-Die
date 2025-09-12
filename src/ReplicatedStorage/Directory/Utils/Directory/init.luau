local dirAssetsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Directory")
local module = {}

local MT = {}
MT.__index = MT

type anytype = string & number & { [string]: any } & ModuleScript

export type ClassType<ModuleScriptDirectory = typeof(script.Parent.Parent.Template)> = typeof(setmetatable(
	{} :: {
		directoryAssetsFolder: Folder,
		directoryFolder: ModuleScriptDirectory & ModuleScript,
	},
	MT
))

function module.newDirectory<ModuleScriptDirectory>(directoryFolder: ModuleScriptDirectory & Instance): ClassType<ModuleScriptDirectory>?
	if not directoryFolder or not directoryFolder:IsA("ModuleScript") then
		return nil
	end
	local self = setmetatable({
		directoryAssetsFolder = dirAssetsFolder:FindFirstChild(directoryFolder.Name) :: typeof(directoryFolder),
		directoryFolder = directoryFolder,
	}, MT) :: ClassType<ModuleScriptDirectory>
	return self
end

function MT:getItemInfo(itemId: anytype)
	local itemType = typeof(itemId)
	if itemType == "string" or itemType == "number" then
		for _, mod in self.directoryFolder:GetChildren() do
			if tonumber(itemId) == tonumber(mod.Name:match("^(.-) _ ")) then
				return require(mod)
			end
		end
	elseif itemType == "Instance" and itemId:IsA("ModuleScript") then
		return require(itemId)
	end

	return itemId
end

function MT.getItemModule(self: ClassType, item: anytype) --: typeof(self.directoryFolder["00 | Template"])
	local itemtype = type(item)
	if itemtype == "table" then
		return self.directoryFolder:FindFirstChild(string.format("%02d", item.Id) .. " _ " .. item.Name)
	elseif itemtype == "number" or itemtype == "string" then
		local childs = self.directoryFolder:GetChildren()
		for _, value in childs do
			local keyId = tonumber(value.Name:match("^(%d+)%s*_"))
			if keyId == tonumber(item) then
				return value
			end
		end
	end

	return item --:: typeof(self.directoryFolder["00 | Template"])
end

function MT.getDirectoryAssetsFolder(self: ClassType, item: anytype): Folder?
	local itemtype = type(item)
	if itemtype == "table" then
		local found = self.directoryAssetsFolder:FindFirstChild(string.format("%02d", item.Id) .. " _ " .. item.Name)
		return found and found:IsA("Folder") and found :: Folder or nil
	elseif itemtype == "number" or itemtype == "string" then
		local childs = self.directoryAssetsFolder:GetChildren()
		for _, value in childs do
			local keyId = tonumber(value.Name:match("^(%d+)%s*_"))
			if keyId == tonumber(item) then
				return value:IsA("Folder") and value :: Folder or nil
			end
		end
	end

	return nil
end

function MT.getRandomItemModule<ModuleScriptDirectory>(self: ClassType<ModuleScriptDirectory>): ModuleScript
	local items = self.directoryFolder:GetChildren()
	local randomItem = items[math.random(1, #items)]
	return randomItem
end

function MT.getRandomItemId(self: ClassType): number
	return require(self:getRandomItemModule()).Id
end

function MT.getItemModel(self: ClassType, item: anytype): PVInstance
	local itemModule = self:getDirectoryAssetsFolder(item)
	return itemModule:FindFirstChild("Model") --:: typeof(self.directoryFolder["00 | Template"].Model)
end

function MT.getItemDisplay(self: ClassType, item: anytype): Frame
	local itemModule = self:getDirectoryAssetsFolder(item)
	return itemModule:FindFirstChild("Display") --:: typeof(self.directoryFolder["00 | Template"].Display)
end

--local Items = directorysFolder:WaitForChild('Items')
--local Chests = directorysFolder:WaitForChild('Chests')
--local SecurityCameras = directorysFolder:WaitForChild('SecurityCameras')
--local Crafts = directorysFolder:WaitForChild('Crafts')

return {
	--Items = module.newDirectory(Items),
	--Chests = module.newDirectory(Chests),
	--SecurityCameras = module.newDirectory(SecurityCameras),
	--Crafts = module.newDirectory(Crafts),
	newDirectory = module.newDirectory,
}
