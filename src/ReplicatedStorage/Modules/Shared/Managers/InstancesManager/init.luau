local objectTypeUtil = require(game.ReplicatedStorage.Modules.Shared.Classes.BaseClasses.ObjectType)
local trove = require(game.ReplicatedStorage.lib.lib.ModuleUtils._Trove)

export type genericObjType = {
	UID: string,
	Destroying: boolean?,
} & { [string]: any } & objectTypeUtil.ClassType

local module = {}
module.Trove = trove.new()
module.objsCreated = {
	ToReplicate = {} :: { [string]: genericObjType },
	NotToReplicate = {} :: { [string]: genericObjType },
}

function module.Replicate<T>(self: T & genericObjType, replicate: boolean?): T & genericObjType
	local UID = self.UID
	local notToReplicateTab = module.objsCreated.NotToReplicate
	local toReplicateTab = module.objsCreated.ToReplicate

	replicate = replicate == nil and true or replicate

	if replicate and notToReplicateTab[UID] then
		notToReplicateTab[UID] = nil
		toReplicateTab[UID] = self
		self:ReplicateTo()
	else
		toReplicateTab[UID] = nil
		notToReplicateTab[UID] = self
	end

	return self
end

function module.addObj(self: genericObjType, replicate: boolean?)
	module.Trove:Add(self)
	module.Replicate(self, replicate)
end

function module.removeObj(UID: string)
	local obj = module.getObj(UID)
	if not obj then
		return
	end
	module.objsCreated.ToReplicate[UID] = nil
	module.objsCreated.NotToReplicate[UID] = nil

	if not obj.Destroying then
		if (obj :: any).Destroy then
			(obj :: any):Destroy()
		end
	end
	module.Trove:Remove(obj)
end

function module.getObj(UID: string)
	return module.objsCreated.ToReplicate[UID] or module.objsCreated.NotToReplicate[UID]
end

local function findInTab(tab: { [any]: any }, info: { [any]: any })
	for k, v in info do
		if tab[k] ~= v then
			return false
		end
	end
	return true
end

function module.FindInstanceWithKeys(info: { [any]: any }, replicable: boolean?)
	local tabToFind = (replicable == true and module.objsCreated.ToReplicate)
		or (replicable == false and module.objsCreated.NotToReplicate)
		or nil
	if tabToFind then
		for _, tab in tabToFind do
			if findInTab(tab, info) then
				return tab
			end
		end
	else
		for _, tab in module.objsCreated.ToReplicate do
			if findInTab(tab, info) then
				return tab
			end
		end
		for _, tab in module.objsCreated.NotToReplicate do
			if findInTab(tab, info) then
				return tab
			end
		end
	end

	return nil
end

return module
