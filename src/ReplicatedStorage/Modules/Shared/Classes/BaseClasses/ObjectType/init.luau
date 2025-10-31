local module = {}
local MT = {}

export type ClassType<T = {}, N = string> =
	typeof(setmetatable({} :: { ClassName: N, _Type: { [string]: string } }, { __index = MT }))
	& T

function MT.IsA<T, N>(self: ClassType<T, N>, className: string): boolean
	return self._Type[className] ~= nil
end

function MT.ExtendType<T, N>(self: ClassType<T, N>, typeName: N): ClassType<T, N>
	-- warn("-=-=-=--=-=-= Extending Type: ", typeName, " =-=-=-=--=-=-")
	-- warn("before self 				->", tostring(self), self)
	-- print("before normal types 		->", tostring(self._Type), self._Type)
	-- print("before normal ClassName 	->", self.ClassName)

	local types = table.clone(self._Type)
	types[typeName] = typeName

	-- print("before raw types			->", tostring(rawget(self, "_Type")), rawget(self, "_Type"))
	-- print("before raw ClassName		->", rawget(self, "ClassName"))

	rawset(self, "_Type", types)
	--self._Type[typeName] = typeName
	rawset(self, "ClassName", typeName)

	-- print("after raw types 			->", tostring(rawget(self, "_Type")), rawget(self, "_Type"))
	-- print("after raw ClassName 		->", rawget(self, "ClassName"))

	-- --self.ClassName = typeName

	-- warn("after self 					->", tostring(self), self)
	-- print("after normal types 			->", tostring(self._Type), self._Type)
	-- print("after normal ClassName 		->", self.ClassName)

	return self :: ClassType<T, N>
end

function module.new<T, N>(): ClassType<T, N>
	return setmetatable({
		_Type = {},
		ClassName = "",
	}, { __index = MT }):ExtendType("TypeObject") :: ClassType<T, N>
end

return module
