local serverStorage = game:GetService('ServerStorage')
local replicatedStorage = game:GetService("ReplicatedStorage")
local lib = require(replicatedStorage.lib)
local signal = lib.ModuleUtils.Signal
local trove = lib.ModuleUtils.Trove
local t = lib.FunctionUtils.t

local isPlayer = t.instance('Player')

local timeForPrisonerBeForgotten = require(serverStorage.Modules.GameSettings).TimeForPrisonerBeForgotten

local module = {}

module.Prisoners = {} :: {
	[Player]: {
		flagLevel: number,
		timeOutThread: thread, 
		wanted: boolean,
	}
}
module.PrisonerWantedAdded = signal.new()
module.PrisonerWantedRemoved = signal.new()

module.Trove = trove.new()
module.Trove:Add(module.PrisonerWantedAdded)
module.Trove:Add(module.PrisonerWantedRemoved)

function HowManyPrisonersBeenChased()
	local n = 0
	for _ in module.PrisonersWanted do
		n+=1
	end
	return n
end

function module.AddPrisonerWanted(player: Player)
	if not isPlayer(player) then return end
	
	module.PrisonersWanted[player] = task.delay(timeForPrisonerBeForgotten, function()
		module.RemovePrisonerWanted(player)
	end)
	
	
	
	module.PlayerWantedAdded:Fire(player)
end

function module.RemovePrisonerWanted(player: Player)
	if not isPlayer(player) then return end
	
	
	
	
end


function module.FlagPrisoner(player: Player, flagLevel: number)
	if not isPlayer(player) or not t.number(flagLevel) then return end
	local prisionerTab = module.Prisoners[player]
	if not prisionerTab then return end
	
	if prisionerTab.timeOutThread then
		task.cancel(prisionerTab.timeOutThread)
		prisionerTab.timeOutThread = nil
	end
	
	prisionerTab.flagLevel += flagLevel
	prisionerTab.timeOutThread = task.delay(timeForPrisonerBeForgotten, function()
		module.RemovePrisonerWanted(player)
	end)
	

end




return module
