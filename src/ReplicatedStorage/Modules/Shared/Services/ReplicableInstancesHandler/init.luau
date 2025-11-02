local ProcessInstancePhysicsService = game:GetService("ProcessInstancePhysicsService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local ReplicasFolder = replicatedStorage:WaitForChild("Modules"):WaitForChild("Client"):WaitForChild("Replicas")

local lib = require(replicatedStorage:WaitForChild("lib"))
local trove = lib.ModuleUtils.Trove
local remotesList = lib.Remotes
local instancesManager = require(replicatedStorage.Modules.Shared.Managers.InstancesManager)

local instanceCreatedEventList = remotesList.instanceCreated

local funcAllowedToCall = runService:IsServer()
		and require(game:GetService("ServerStorage").Modules.Configurations.FunctionsAllowedToSendToServer)
	or nil

local module = {}
local pendingCalls = {} :: { [string]: { { string } } }

function module.Init()
	module.Remote = remotesList.UpdateObj
	module.Trove = trove.new()
end

function module.Start()
	if runService:IsServer() then
		module.Remote.OnServerEvent:Connect(function(plr, uid, funcName, args: { any })
			local obj = instancesManager.getObj(uid)
			if not obj then
				return
			end
			local typeKey = obj.ClassName
			local allowed = typeKey and funcAllowedToCall[typeKey]
			if allowed and allowed[funcName] then
				warn(obj, typeKey, obj.UID, funcName)
				warn(plr, table.unpack(args or {}))
				obj[funcName](obj, plr, table.unpack(args or {}))
			end
		end)

		module.Trove:Add(remotesList.PlayerLoaded.OnServerEvent:Connect(function(plr)
			for _, obj in instancesManager.objsCreated.ToReplicate do
				task.spawn(obj.ReplicateTo, obj, plr)
			end
		end))
	else
		local modules = {}
		for _, replicaModule in ReplicasFolder:GetChildren() do
			modules[replicaModule.Name] = require(replicaModule)
		end
		remotesList.instanceCreated.OnClientEvent:Connect(function(instanceType: string, UID: string)
			if instancesManager.getObj(UID) then
				return
			end
			local moduleName = instanceType .. "Replica"
			local moduleScript = modules[moduleName].new(UID)
			if moduleScript then
				-- Flush any pending update calls that arrived before creation
				local obj = instancesManager.getObj(UID)
				local queue = pendingCalls[UID]
				if obj and queue then
					for _, call in queue do
						local funcName, args = call[1], call[2]
						if obj[funcName] then
							obj[funcName](obj, table.unpack(args or {}))
						end
					end
					pendingCalls[UID] = nil
				end
			end
		end)

		-- for name, remote in instanceCreatedEventList do
		-- 	local moduleName = name .. "Replica"
		-- 	local moduleScript = ReplicasFolder:FindFirstChild(moduleName)
		-- 	if moduleScript then
		-- 		modules[name] = require(moduleScript)
		-- 	end

		-- 	remote.OnClientEvent:Connect(function(UID: string, ...)
		-- 		if instancesManager.getObj(UID) then
		-- 			return
		-- 		end
		-- 		modules[name].new(UID, ...)
		-- 		-- Flush any pending update calls that arrived before creation
		-- 		local obj = instancesManager.getObj(UID)
		-- 		local queue = pendingCalls[UID]
		-- 		if obj and queue then
		-- 			for _, call in queue do
		-- 				local funcName, args = call[1], call[2]
		-- 				if obj[funcName] then
		-- 					obj[funcName](obj, table.unpack(args or {}))
		-- 				end
		-- 			end
		-- 			pendingCalls[UID] = nil
		-- 		end
		-- 		--return true
		-- 	end)
		-- end

		module.Trove:Add(module.Remote.OnClientEvent:Connect(function(uid, funcName, args: { any })
			local obj = instancesManager.getObj(uid)
			if not obj then
				-- Buffer update until instanceCreated arrives
				local q = pendingCalls[uid]
				if not q then
					q = {}
					pendingCalls[uid] = q
				end
				table.insert(q, { funcName, args or {} })
				return
			end
			local typeKey = obj.ClassName
			warn(obj, typeKey, obj.UID)
			warn(funcName)
			warn(args)
			obj[funcName](obj, table.unpack(args or {}))
		end))
	end
end

return module
