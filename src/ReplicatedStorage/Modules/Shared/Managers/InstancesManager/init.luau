local trove = require(game.ReplicatedStorage.lib.lib.ModuleUtils._Trove)

export type TypeMap = { [string]: string, _primary: string?, _current: string? }

local function cloneTypeMap(map: TypeMap?): TypeMap
	local copy: TypeMap = {}
	if not map then
		return copy
	end
	for key, value in map do
		copy[key] = value
	end
	copy._primary = map._primary
	copy._current = map._current
	return copy
end

export type genericObjType = {
	_Type: TypeMap,
	UID: string,
	Destroying: boolean?,
} & { [string]: any }

local module = {}
module.Trove = trove.new()
module.objsCreated = {
	ToReplicate = {} :: { [string]: genericObjType },
	NotToReplicate = {} :: { [string]: genericObjType },
}

function module.buildTypeMap(typeName: string, baseMap: TypeMap?): TypeMap
	local map = cloneTypeMap(baseMap)
	map[typeName] = typeName
	map._primary = map._primary or typeName
	map._current = typeName
	return map
end

function module.getPrimaryType(typeData: string | TypeMap | nil): string?
	if type(typeData) == "table" then
		local map = typeData :: TypeMap
		return map._current or map._primary or next(map :: { [string]: string })
	end
	return type(typeData) == "string" and (typeData :: string) or nil
end

function module.typeIs(typeData: string | TypeMap | nil, query: string): boolean
	if type(typeData) == "table" then
		return (typeData :: TypeMap)[query] ~= nil
	elseif type(typeData) == "string" then
		return typeData == query
	end
	return false
end

function module.objectIs(obj: genericObjType?, query: string): boolean
	if not obj then
		return false
	end
	return module.typeIs(obj._Type, query)
end

function module.Replicate<T>(self: T & genericObjType, replicate: boolean?)
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
