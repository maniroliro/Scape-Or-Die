local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")
local playersServices = game:GetService("Players")

local lib = require(replicatedStorage.lib)
local trove = lib.ModuleUtils.Trove

local collisionGroupUtils = require(serverStorage.Modules.Utils.CollisionGroup)

local module = {}
module.Trove = trove.new()

function module.Init()
	collisionGroupUtils.CollisionGroupSetCollidable("PlayersCharacters", "GuardsCharacters", false)
	collisionGroupUtils.CollisionGroupSetCollidable("GuardsCharacters", "GuardsCharacters", false)
	collisionGroupUtils.CollisionGroupSetCollidable("PlayersCharacters", "PlayersCharacters", false)
end

function module.Start()
	for _, player in pairs(playersServices:GetPlayers()) do
		local character = player.Character

		if character then
			collisionGroupUtils.setModelCollisionGroup(character, "PlayersCharacters")
		end

		player.CharacterAdded:Connect(function(char)
			collisionGroupUtils.setModelCollisionGroup(char, "PlayersCharacters")
		end)
	end

	module.Trove:Add(playersServices.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			collisionGroupUtils.setModelCollisionGroup(character, "PlayersCharacters")
		end)
	end))
end

return module
