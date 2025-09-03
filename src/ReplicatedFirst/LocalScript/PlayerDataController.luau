local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lib = require(ReplicatedStorage.lib)
local TableToRemoteTable = lib.Utils.TableToRemoteTable
local tableUtil = lib.FunctionUtils.Table
local remotes = lib.Remotes
local playerDataUpdatedEvent = remotes.PlayerDataUpdated

local playerDataModule = require(ReplicatedStorage.Modules.Client.PlayerData)

local module = {}

function module.Init()
	
end

function module.Start()
	playerDataUpdatedEvent.OnClientEvent:Connect(function(new)
		warn('New Player Data Received:', new)
		new = TableToRemoteTable.decode(new)
		playerDataModule.NewDataReceived:Fire(new)
		if not tableUtil.checkTableEquality(playerDataModule.Data, new) then
			playerDataModule.Data = new
			warn('Player Data Updated:', new)
			playerDataModule.DataUpdated:Fire(new)
		end
	end)
	
end

return module