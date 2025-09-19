local replicatedStorage = game:GetService("ReplicatedStorage")
--local playersService = game:GetService("Players")

local lib = require(replicatedStorage.lib)
local remotes = lib.Remotes
local playerLoaded = remotes.PlayerLoaded

local Assets = replicatedStorage.Assets
local rigsFolder = Assets.Rigs
local prisionerRig = rigsFolder.Prisoner

local changePlayerCharacter = require(game:GetService("ServerStorage").Modules.Utils.ChangePlayerCharacter)

local module = {}

function module.Init() end

function module.Start()
	playerLoaded.OnServerEvent:Connect(function(player: Player)
		--playersService.PlayerAdded:Connect(function(player: Player)
		changePlayerCharacter(player, prisionerRig)
		player.CharacterAdded:Connect(function()
			changePlayerCharacter(player, prisionerRig)
		end)
	end)
end

return module
