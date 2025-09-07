local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lib = require(ReplicatedStorage.lib)
local Signal = lib.ModuleUtils.Signal

local module = {}
module.Data = nil
module.NewDataReceived = Signal.new()
module.DataUpdated = Signal.new()

function module.GetData()
	local data = module.Data
	if data then
		return data
	end

	while not data do
		task.wait(0.5)
	end

	return data
end

return module
