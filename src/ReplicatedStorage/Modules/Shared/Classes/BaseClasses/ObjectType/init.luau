local module = {}
local MT = {}

export type ClassType<Tab = any> =
	typeof(setmetatable({} :: { ClassName: string, _Type: { [string]: string } }, { __index = MT }))
	& Tab

function MT.IsA<Tab>(self: ClassType<Tab>, className: string): boolean
	return self._Type[className] ~= nil
end

function MT.ExtendType<Tab>(self: Tab, typeName: string): Tab
	(self :: any)._Type[typeName] = typeName;
	(self :: any).ClassName = typeName

	return self :: Tab
end

function module.new(): ClassType
	return setmetatable({
		_Type = {},
		ClassName = "TypeObject",
	}, { __index = MT })
end

return module
