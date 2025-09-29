local serverStorage = game:GetService("ServerStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")
local playersService = game:GetService("Players")
local lib = require(replicatedStorage.lib)
local signal = lib.ModuleUtils.Signal
local trove = lib.ModuleUtils.Trove
local t = lib.FunctionUtils.t

local timeForPrisonerBeForgotten = require(serverStorage.Modules.Configurations.GameSettings).TimeForPrisonerBeForgotten

local module = {}

module.Prisoners = {} :: {
	[Player]: {
		flagLevel: number,
		timeOutThread: thread,
		wanted: boolean,
	},
}
module.PrisonerWantedAdded = signal.new()
module.PrisonerWantedRemoved = signal.new()

module.Trove = trove.new()
module.Trove:Add(module.PrisonerWantedAdded)
module.Trove:Add(module.PrisonerWantedRemoved)
module.Trove:Connect(playersService.PlayerAdded, function(plr: Player)
	module.Prisoners[plr] = {
		flagLevel = 0,
		timeOutThread = nil,
		wanted = false,
	}
end)
module.Trove:Connect(playersService.PlayerRemoving, function(plr: Player)
	local plrTab = module.Prisoners[plr]
	if not plrTab then
		return
	end
	local plrThread = plrTab.timeOutThread
	if plrThread then
		task.cancel(plrThread)
		plrTab.timeOutThread = nil
	end
	module.Prisoners[plr] = nil
end)

function HowManyPrisonersBeingChased()
	local n = 0
	for plr in module.Prisoners do
		if plr.wanted then
			n += 1
		end
	end
	return n
end

function module.AddPrisonerWanted(player: Player)
	if not t.instance(player, "Player") then
		return
	end

	module.Prisoners[player].timeOutThread = task.delay(timeForPrisonerBeForgotten, function()
		module.RemovePrisonerWanted(player)
	end)

	module.PrisonerWantedAdded:Fire(player)
end

function module.RemovePrisonerWanted(player: Player)
	if not t.instance(player, "Player") then
		return
	end
end

function module.FlagPrisoner(player: Player, flagLevel: number?)
	flagLevel = flagLevel or 1
	if not t.Player(player) or not t.number(flagLevel) then
		return
	end
	local prisonerTab = module.Prisoners[player]
	if not prisonerTab then
		return
	end

	if prisonerTab.timeOutThread then
		task.cancel(prisonerTab.timeOutThread)
		prisonerTab.timeOutThread = nil
	end

	prisonerTab.flagLevel += flagLevel
	prisonerTab.timeOutThread = task.delay(timeForPrisonerBeForgotten, function()
		module.RemovePrisonerWanted(player)
	end)
end

return module
