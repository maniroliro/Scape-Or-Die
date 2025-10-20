local objectTypeUtil = require(game.ReplicatedStorage.Modules.Shared.Utils.ObjectType)
local trove = require(game.ReplicatedStorage.lib.lib.ModuleUtils._Trove)

export type genericObjType = {
	_Type: objectTypeUtil.TypeMap,
	UID: string,
	Destroying: boolean?,
} & { [string]: any }

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

return module
