local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")
local playersService = game:GetService("Players")

local prisonerClass = require(serverStorage.Modules.Classes.Prisoner)

playersService.PlayerAdded:Connect(function(plr)
	local newPrisoner = prisonerClass.new()
	newPrisoner:SetController(plr)
	newPrisoner:Replicate(true)

	print("ccccccccccccccccccc", newPrisoner)
end)

return {}
