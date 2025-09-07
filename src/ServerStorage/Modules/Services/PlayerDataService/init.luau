local serverStorage = game:GetService('ServerStorage')
local playersService = game:GetService('Players')
local remotes = require(game:GetService('ReplicatedStorage').lib.Remotes)
local playerLoadedEvent = remotes.PlayerLoaded

local playerData = {}
playerData.manage = require(serverStorage.Modules.Managers.PlayerDataManager)

local profileStore = require(script.ProfileStore)

local plrData = profileStore.New('PlayerInfo', playerData.manage.getPlayerTemplateData())

function playerData.Init()
	
end

function playerData.Start()
	--playersService.PlayerAdded:Connect(playerData.startPlayer)
	playerLoadedEvent.OnServerEvent:Connect(function(plr) playerData.startPlayer(plr) end)
	playersService.PlayerRemoving:Connect(playerData.finishPlayer)
end

function playerData.startPlayer(plr : Player)
	local profile = plrData:StartSessionAsync('Player_'.. plr.UserId, {
		Cancel = function()
			return plr.Parent ~= playersService
		end,
	})

	if not profile then 
		print('error: 1 Rejoin, an error occurred')
	else
		profile:AddUserId(plr.UserId)
		profile:Reconcile()

		profile.OnSessionEnd:Connect(function()
			playerData.manage._cache[plr] = nil
			plr:Kick('error: 2 Rejoin, an error occurred')
		end)

		if plr.Parent == playersService then
			playerData.manage.setStats(plr, profile)
			--playerData.manage.updateClient(plr)
		else
			profile:EndSession()
		end
	end
	--playerData.manage.resetStat(plr)
end

function playerData.finishPlayer(plr: Player)
	local profile = playerData.manage.getPlayerSalvableData(plr)
	print(profile)
	if not profile then return end
	--playerData.manage.resetStat(plr)
	profile:EndSession()
	playerData.manage._cache[plr] = nil
end

return playerData