local replicatedStorage = game:GetService("ReplicatedStorage")
local lib = require(replicatedStorage.lib)
local packet = lib.ModuleUtils.Packet
local remotes = lib.Remotes
local playerDataUpdatedRemote = remotes.PlayerDataUpdated
local TableToRemoteTable = lib.Utils.TableToRemoteTable

local updateStatsEvent = remotes.PlayerDataUpdated

local privatePlayerDataTemplate = require(script.PrivatePlayerDataTemplate)
local PublicPlayerDataTemplate = require(script.PublicPlayerDataTemplate)
local InGamePlayerDataTemplate = require(script.PublicPlayerDataTemplate.InGamePlayerDataTemplate)

local dataManager = {}
dataManager._cache = {}

function dataManager.getProfile(plr)
	if not plr:IsA("Player") then
		return
	end
	return dataManager._cache[plr]
end

function dataManager.getProfileData(
	plr
): privatePlayerDataTemplate.TemplateData & PublicPlayerDataTemplate.TemplateData & InGamePlayerDataTemplate.TemplateData
	if not plr:IsA("Player") then
		return
	end
	return dataManager._cache[plr].Data
end

function dataManager.getPlayerTemplateData()
	local newData = {}

	for k, v in privatePlayerDataTemplate do
		newData[k] = v
	end
	for k, v in PublicPlayerDataTemplate do
		newData[k] = v
	end
	for k, v in InGamePlayerDataTemplate do
		newData[k] = v
	end

	return newData
end

function dataManager.getPlayerSalvableData(plr: Player)
	local profile = dataManager.getProfile(plr)
	if not profile then
		return
	end

	for k in profile.Data do
		if not PublicPlayerDataTemplate[k] and not privatePlayerDataTemplate[k] then
			profile.Data[k] = nil
		end
	end

	return profile
end

function dataManager.updateClient(plr: Player)
	local profile = dataManager.getProfileData(plr)
	if not profile then
		return
	end

	for k in profile do
		if not PublicPlayerDataTemplate[k] and not InGamePlayerDataTemplate[k] then
			profile[k] = nil
		end
	end

	local data = TableToRemoteTable.encode(profile)
	playerDataUpdatedRemote:FireClient(plr, data)
	--task.spawn(updateStatsEvent.FireClient, updateStatsEvent, plr, TableToRemoteTable.encode(profile))
end

function dataManager.setStats(plr: Player, key: any, value: any?)
	if value then
		local profile = dataManager.getProfileData(plr)
		if not profile then
			return
		end

		profile[key] = value
	else
		dataManager._cache[plr] = key
	end

	dataManager.updateClient(plr)
end

function dataManager.resetStat(plr: Player, key: string?)
	local profile = dataManager.getProfile(plr)
	if not profile then
		return
	end

	local template = dataManager.getPlayerTemplateData()
	if key then
		profile.Data[key] = template[key]
	else
		profile.Data = template
	end

	dataManager.updateClient(plr)
end

function dataManager.increaseStats(plr: Player, key: string, value: number)
	if not key or not value then
		return
	end

	local profile = dataManager.getProfileData(plr)
	if not profile then
		return
	end

	profile[key] += value

	dataManager.updateClient(plr)
end

function dataManager.decreaseStats(plr: Player, key: string, value: number)
	if not key or not value then
		return
	end

	local profile = dataManager.getProfileData(plr)
	if not profile then
		return
	end

	profile[key] -= value

	dataManager.updateClient(plr)
end

function dataManager.get(plr: Player)
	return dataManager.getProfileData(plr)
end

--[[local function findPath(key, plr)
	local profile = getProfile(plr)
	if not profile then return end 
	local path = profile.Data
	if typeof(key) == 'string' then return path[key], profile end
	if typeof(key) == 'table' then 
		for i, k in key do
			path = path[k]
		end
		return path, profile
	end
end]]

--[[function dataManager.updateStats(plr: Player, key, value)
	if not plr or not key or not value then return end
	
	local playerData = getProfile(plr)
	if not playerData then return end
	
	
	
	
	
end]]

--[[function dataManager.updateStats(plr: Player, key : string | {[number] : string}, value : any, operation : string?, notUpdate:boolean?)
	if not plr or not key or not value then return end
	local path, profile
	if typeof(key) == 'table' then
		path, profile = findPath(key, plr)
		if typeof(path) ~= typeof(value) then return end
		
		path = rL.Functions.DeepUpdate(operation and operation or '+', path, value)
	else
		profile = getProfile(plr)
		if not profile then return end 
		profile.Data[key] = rL.Functions.DeepUpdate(operation and operation or '+', profile.Data[key], value)
	end
	if not notUpdate then updateStatsEvent:FireClient(plr, profile.Data) end
end]]

return dataManager
