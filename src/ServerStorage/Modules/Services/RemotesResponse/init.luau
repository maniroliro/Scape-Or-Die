local replicatedStorage = game:GetService("ReplicatedStorage")

local lib = require(replicatedStorage.lib)
local remotes = lib.Remotes
local packet = lib.ModuleUtils.Packet

local module = {}
module.remotesList = {
	"CraftItem",
}
module.modules = {}

function module.Init()
	for _, child in script:GetChildren() do
		if child:IsA("ModuleScript") then
			local mod = require(child)
			module.modules[child.Name] = mod
		end
	end
end

function module.Start()
	for _, remoteName in module.remotesList do
		local remote: lib.Packet<any> = remotes[remoteName]
		if remote then
			remote.OnServerEvent:Connect(module.modules[remoteName])
		end
	end
end

return module
