local fs = require("@lune/fs")
local roblox = require("@lune/roblox")

--==========SETTINGS===========--
local FILE_TO_READ = "toRojo.rbxl"

local parsedFile = fs.readFile(FILE_TO_READ)
local game = roblox.deserializePlace(parsedFile)

local outputFolder = "src"

local FileTypeByInstanceClassName = {
	["ModuleScript"] = ".luau",
	["Script"] = ".server.luau",
	["LocalScript"] = ".client.luau",
	--["Model"] = ".model",
	--["Decal"] = ".decal",
	--["Sound"] = ".sound",
	--["Texture"] = ".texture",
	--["Part"] = ".part",
}

local ScriptClassNames = {
	["ModuleScript"] = true,
	["Script"] = true,
	["LocalScript"] = true,
}

--===============================--

local function CreateFolderByPath(path: string)
	fs.writeDir(path)
end

local function IsInstanceInteresting(instance: Instance): boolean
	if FileTypeByInstanceClassName[instance.ClassName] == nil then
		return false
	end
	return true
end

local function RemoveGarbageFromXMLScriptFile(scriptFile: string, startConstant: string, endConstant: string)
	local startIndex = scriptFile:find(startConstant)

	if not startIndex then
		return scriptFile
	end
	startIndex += startConstant:len()

	scriptFile = scriptFile:sub(startIndex, -1)

	local endIndex = scriptFile:find(endConstant) or -1
	scriptFile = scriptFile:sub(1, endIndex - 1)

	return scriptFile
end

local function OutputFileFromInstanceByPath(instance, path: string)
	if IsInstanceInteresting(instance) == false then
		return
	end

	local className = instance.ClassName

	local fileName = instance.Name
	local fileType = FileTypeByInstanceClassName[className]

	if fileType ~= nil then
		fileName = fileName .. fileType
	else
		fileName = fileName .. "." .. className
	end

	local file = roblox.serializeModel({ instance }, true)
	if ScriptClassNames[className] == true then
		file = RemoveGarbageFromXMLScriptFile(file, '<string name="Source">', "</string>")
		file = RemoveGarbageFromXMLScriptFile(file, "<!%[CDATA", "%]%]>")
	end

	if path:sub(-1, -1) ~= "/" then
		path = path .. "/"
	end

	fs.writeFile(path .. fileName, file)
end

local function ParseAllDescendants(startingFolder: Folder, outputPath: string)
	if outputPath:find("/") == nil then
		outputPath = outputFolder .. "/" .. outputPath
	end

	CreateFolderByPath(outputPath)

	--print("starting folder: " .. startingFolder.Name)
	--print("current outputPath: " .. outputPath)

	for _, child in startingFolder:GetChildren() do
		--print("current child: " .. child.Name)
		if IsInstanceInteresting(child) == true then
			--print("!!child was considered insteresting, writing to file...!!")
			OutputFileFromInstanceByPath(child, outputPath)
		end

		if #child:GetChildren() > 0 then
			ParseAllDescendants(child, outputPath .. "/" .. child.Name)
		end
	end
end

local function CreateAllFoldersInsideFolderWithStartingPath(startingFolder: Folder, outputPath: string)
	if outputPath:find("/") == nil then
		outputPath = outputFolder .. "/" .. outputPath
	end

	if startingFolder.ClassName == "Folder" then
		fs.writeDir(outputPath)
	end

	for _, child in startingFolder:GetChildren() do
		if child.ClassName == "Folder" then
			fs.writeDir(outputPath .. "/" .. child.Name .. "/")
			CreateAllFoldersInsideFolderWithStartingPath(child, outputPath .. "/" .. child.Name .. "/")
		end
	end
end

local function CreateAndParseFolderWithStartingPath(startingFolder: Folder, outputPath: string)
	CreateAllFoldersInsideFolderWithStartingPath(startingFolder, outputPath)
	ParseAllDescendants(startingFolder, outputPath)
end

--CreateAndParseFolderWithStartingPath(game:GetService("Workspace"), "Workspace")
--CreateAndParseFolderWithStartingPath(game:GetService("StarterGui"), "StarterGUI")
CreateAndParseFolderWithStartingPath(game:GetService("ServerScriptService"), "Server")
CreateAndParseFolderWithStartingPath(game:GetService("ServerStorage"), "ServerStorage")
CreateAndParseFolderWithStartingPath(game:GetService("ReplicatedFirst"), "ReplicatedFirst")
CreateAndParseFolderWithStartingPath(game:GetService("ReplicatedStorage"), "ReplicatedStorage")
--CreateAndParseFolderWithStartingPath(game:GetService("StarterPlayer"), "StarterPlayer")
