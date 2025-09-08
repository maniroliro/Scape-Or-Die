--!nocheck
---@diagnostic disable-next-line
local fs = require("@lune/fs")
---@diagnostic disable-next-line
local roblox = require("@lune/roblox")

--==========SETTINGS===========--
local FILE_TO_READ = "toRojo.rbxl"

local parsedFile = fs.readFile(FILE_TO_READ)
local game = roblox.deserializePlace(parsedFile)

local outputFolder = "src"

-- Sanitiza nomes para filesystem Windows (remove caracteres inválidos e reserva palavras)
local function sanitizeName(name: string): string
	-- Substitui caracteres inválidos por '_'
	local cleaned = name:gsub('[<>:"/\\|%?%*]', "_")
	-- Remove controles
	cleaned = cleaned:gsub("%c", "")
	-- Trim espaços finais e pontos (inválidos no fim em Windows)
	cleaned = cleaned:gsub("[%. ]+$", "")
	if cleaned == "" then
		cleaned = "_"
	end
	-- Palavras reservadas no Windows
	local upper = cleaned:upper()
	local reserved = {
		CON = true,
		PRN = true,
		AUX = true,
		NUL = true,
		COM1 = true,
		COM2 = true,
		COM3 = true,
		COM4 = true,
		COM5 = true,
		COM6 = true,
		COM7 = true,
		COM8 = true,
		COM9 = true,
		LPT1 = true,
		LPT2 = true,
		LPT3 = true,
		LPT4 = true,
		LPT5 = true,
		LPT6 = true,
		LPT7 = true,
		LPT8 = true,
		LPT9 = true,
	}
	if reserved[upper] then
		cleaned = cleaned .. "_"
	end
	return cleaned
end

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

-- Função para decodificar entidades HTML
local function decodeHTMLEntities(text: string): string
	-- Decodifica as entidades HTML mais comuns
	text = text:gsub("&lt;", "<")
	text = text:gsub("&gt;", ">")
	text = text:gsub("&amp;", "&")
	text = text:gsub("&quot;", '"')
	text = text:gsub("&#39;", "'")
	text = text:gsub("&apos;", "'")
	return text
end

local function OutputFileFromInstanceByPath(instance, path: string)
	if IsInstanceInteresting(instance) == false then
		return
	end

	local className = instance.ClassName

	local baseName = sanitizeName(instance.Name)
	local fileType = FileTypeByInstanceClassName[className]
	local fileName
	if ScriptClassNames[className] then
		-- Use padrão pasta + init.* (Rojo: diretório vira ModuleScript com children)
		if fileType then
			-- fileType já inclui sufixo (.luau / .server.luau / .client.luau)
			local ext = fileType
			fileName = "init" .. ext
		else
			fileName = "init." .. className
		end
	else
		if fileType then
			fileName = baseName .. fileType
		else
			fileName = baseName .. "." .. className
		end
	end

	local file = roblox.serializeModel({ instance }, true)
	if ScriptClassNames[className] == true then
		file = RemoveGarbageFromXMLScriptFile(file, '<string name="Source">', "</string>")
		file = RemoveGarbageFromXMLScriptFile(file, "<!%[CDATA", "%]%]>")
		-- Decodifica entidades HTML no código do script
		file = decodeHTMLEntities(file)
	end

	if path:sub(-1, -1) ~= "/" then
		path = path .. "/"
	end

	-- Para qualquer script, sempre criar pasta homônima e colocar o arquivo dentro dela
	if ScriptClassNames[className] == true then
		local scriptFolder = path .. baseName .. "/"
		fs.writeDir(scriptFolder)
		fs.writeFile(scriptFolder .. fileName, file)
	else
		fs.writeFile(path .. fileName, file)
	end
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
			ParseAllDescendants(child, outputPath .. "/" .. sanitizeName(child.Name))
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
			local safe = sanitizeName(child.Name)
			fs.writeDir(outputPath .. "/" .. safe .. "/")
			CreateAllFoldersInsideFolderWithStartingPath(child, outputPath .. "/" .. safe .. "/")
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

print("Done!")
