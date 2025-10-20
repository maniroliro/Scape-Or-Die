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

local module = {}

function module.buildTypeMap(typeName: string, baseMap: TypeMap?): TypeMap
	local map = cloneTypeMap(baseMap)
	map[typeName] = typeName
	map._primary = map._primary or typeName
	map._current = typeName
	return map
end

function module.getPrimaryType(typeData: string | TypeMap): string?
	if type(typeData) == "table" then
		local map = typeData :: TypeMap
		return map._current or map._primary or next(map :: { [string]: string })
	end
	return type(typeData) == "string" and (typeData :: string) or nil
end

function module.typeIs(typeData: string | TypeMap, query: string): boolean
	if type(typeData) == "table" then
		return (typeData :: TypeMap)[query] ~= nil
	elseif type(typeData) == "string" then
		return typeData == query
	end
	return false
end

return module
