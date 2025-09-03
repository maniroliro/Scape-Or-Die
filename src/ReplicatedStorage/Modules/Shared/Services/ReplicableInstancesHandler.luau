local replicatedStorage = game:GetService('ReplicatedStorage')
local runService = game:GetService('RunService')
local ReplicasFolder = replicatedStorage:WaitForChild('Modules'):WaitForChild('Client'):WaitForChild('Replicas')

local lib = require(replicatedStorage:WaitForChild('lib'))
local trove = lib.ModuleUtils.Trove
local remotesList = lib.Remotes
local instancesManager = require(replicatedStorage.Modules.Shared.Managers.InstancesManager)

local instanceCreatedEventList = remotesList.instanceCreated

local module = {}

function module.Init()
	module.Remote = remotesList.UpdateObj
	module.Trove = trove.new()
end

function module.Start()
	local modules = {}
	
	if runService:IsServer() then
		local funcAllowedToCall = require(game:GetService('ServerStorage').Modules.Configurations.FunctionsAllowedToSendToServer)
		module.Remote.OnServerEvent:Connect(function(plr, uid, funcName, args: {any})
			local obj = instancesManager.getObj(uid)
			if not obj then return end
			if funcAllowedToCall[obj._Type][funcName] then
				if not obj then return end
				obj[funcName](obj, plr, table.unpack(args or {}))
			end
		end)
		
		module.Trove:Add(remotesList.PlayerLoaded.OnServerEvent:Connect(function(plr)
			for _, obj in instancesManager.objsCreated.ToReplicate do
				task.spawn(obj.ReplicateTo, obj, plr)
			end
		end))
	else
		for name, remote in instanceCreatedEventList do
			local moduleName = name .. 'Replica'
			local moduleScript = ReplicasFolder:FindFirstChild(moduleName)
			if moduleScript then
				modules[name] = require(moduleScript)
			end
			
			remote.OnClientEvent:Connect(function(UID: string, ...)
				print(name)
				if instancesManager.getObj(UID) then return end
				modules[name].new(UID, ...)
				--return true
			end)
		end
		
		module.Trove:Add(module.Remote.OnClientEvent:Connect(function(uid, funcName, args: {any})
			local obj = instancesManager.getObj(uid)
			if not obj then return end
			obj[funcName](obj, table.unpack(args or {}))
		end))
	end
end

return module
