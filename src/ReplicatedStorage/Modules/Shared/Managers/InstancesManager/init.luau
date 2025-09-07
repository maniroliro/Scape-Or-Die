export type genericObjType = {
	_Type: string,
	UID: string,
} & { [string]: any }

local module = {}
module.objsCreated = {
	ToReplicate = {} :: { [string]: { genericObjType } },
	NotToReplicate = {} :: { [string]: { genericObjType } },
}

function module.Replicate(self: genericObjType, replicate: boolean?)
	local UID = self.UID
	local notToReplicateTab = module.objsCreated.NotToReplicate
	local toReplicateTab = module.objsCreated.ToReplicate

	if replicate or notToReplicateTab[UID] then
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
	module.Replicate(self, replicate)
end

function module.removeObj(UID: string)
	local obj = module.getObj(UID)
	if obj then
		obj:Destroy()
		module.objsCreated[UID] = nil
	end
end

function module.getObj(UID: string)
	return module.objsCreated.ToReplicate[UID] or module.objsCreated.NotToReplicate[UID]
end

return module
