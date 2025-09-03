local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local lib = require(replicatedStorage.lib)
local packet = lib.ModuleUtils.Packet
local trove = lib.ModuleUtils.Trove
local getLegalUID = lib.Utils.GetLegalUID
local t = lib.FunctionUtils.t
local remotes = lib.Remotes

local sharedModules = replicatedStorage.Modules.Shared
local instancesManager = require(sharedModules.Managers.InstancesManager)

local module = {}

export type genericObjType = instancesManager.genericObjType

export type ClassType = typeof(setmetatable(
	{}:: {
		Remote: typeof(packet('')),
		Trove: typeof(trove.new()),
	} & genericObjType, 
	{__index = module}
	)
) 

function module.new(UID: string?) : ClassType
	local self = setmetatable({
		UID = UID or getLegalUID(),
		Trove = trove.new(),
		Remote = remotes.UpdateObj,
	}, {__index = module}) :: ClassType
	
	instancesManager.addObj(self)
	return self
end

function module.newLinkedToAClass<T, T2>(realClassModule: {[string]: any}, sharedClassModule: {[string]: any}, UID: string?) : ClassType
	local self = setmetatable(sharedClassModule.new(UID), {
		__index = function(tab, k)
			local func2 = rawget(realClassModule, k)
			if typeof(func2) == 'function' then
				return function(self, ...) 
					local func1 = sharedClassModule[k]
					if func1 then
						func1(tab, ...)
					end

					func2(self, ...) 
				end
			else
				return func2
			end
		end
	})

	return self
end

function module.Replicate<ClassType>(self: ClassType, replicate: boolean?)
	instancesManager.replicate(self, replicate)
	return self
end

function module.AttachId<ClassType>(self: ClassType, id: number)
	local directory = require(replicatedStorage.Directory[self._Type..'s'])
	local info = directory:getItemInfo(id)

	for k, v in info do
		self[k] = v
	end
	return self
end

function module.Materialize<ClassType>(self: ClassType, CF: CFrame?)
	local directory = require(replicatedStorage.Directory[self._Type..'s'])
	local model = directory:getItemModel(self.Id):Clone()

	self.Model = model

	if not t.CFrame(CF) then return self end
	if self.Model then
		self.CFrame = lib.Utils.GetLegalCFrame(CF)
		self.Model.CFrame = self.CFrame
	end
	
	return self
end


return module
