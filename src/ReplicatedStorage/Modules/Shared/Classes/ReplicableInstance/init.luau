local replicatedStorage = game:GetService("ReplicatedStorage")

local lib = require(replicatedStorage.lib)
local packet = lib.ModuleUtils.Packet
local trove = lib.ModuleUtils.Trove
local getLegalUID = lib.Utils.GetLegalUID
local t = lib.FunctionUtils.t
local remotes = lib.Remotes

local sharedModules = replicatedStorage.Modules.Shared
local instancesManager = require(sharedModules.Managers.InstancesManager)

local module = setmetatable({}, { __index = instancesManager })

export type genericObjType = instancesManager.genericObjType

export type ClassType = typeof(setmetatable(
	{} :: {
		Remote: typeof(packet("")),
		Trove: typeof(trove.new()),
	},
	{ __index = module }
)) & genericObjType

function module.new(UID: string?): ClassType
	local self = setmetatable({
		UID = UID or getLegalUID(),
		Trove = trove.new(),
		Remote = remotes.UpdateObj,
	}, { __index = module }) :: ClassType

	instancesManager.addObj(self)
	return self
end

function module.newLinkedToAClass<T, T2>(
	realClassModule: { [string]: any },
	sharedClassModule: { [string]: any },
	UID: string?
): ClassType
	local self = setmetatable(sharedClassModule.new(UID), {
		__index = function(_, k)
			local func1 = rawget(realClassModule, k)

			if typeof(func1) == "function" then
				return func1
			end

			local func2 = sharedClassModule[k]
			if typeof(func2) == "function" then
				return func2
			end

			return func2
		end,
	})

	return self
end

-- function module.Replicate<T>(self: T & ClassType, replicate: boolean?)
-- 	self:Replicate(replicate)
-- 	return self
-- end

function module.AttachId<T>(self: T & ClassType, id: number)
	print(self, id, self.Id)
	local directory = require(replicatedStorage.Directory[self._Type .. "s"])
	local info = directory:getItemInfo(id)

	for k, v in info do
		(self :: any)[k] = v
	end
	return self
end

function module.Materialize<T>(self: T & ClassType, CF: CFrame?)
	local directory = require(replicatedStorage.Directory[self._Type .. "s"])
	local model = directory:getItemModel(self.Id):Clone()

	self.Model = model

	if not CF or not t.CFrame(CF) then
		return self
	end
	if self.Model then
		self.CFrame = lib.Utils.GetLegalCFrame(CF)
		self.Model:PivotTo(self.CFrame)
	end

	return self
end

return module
