local packet = require(game.ReplicatedStorage.lib.lib.ModuleUtils._Packet)

local module = {}
module.remoteTableType = {{Key = packet.String, Value = packet.Any}}

function module.encode(tab: {[string]: any})
	local new = {}

	for k, v in tab do
		new[#new + 1] = {Key = k, Value = v}
	end

	return new
end

function module.decode(tab: {[string]: any})
	local new = {}
	
	for i, v in tab do
		new[v.Key] = v.Value
	end
	
	return new
end

return module
