local module = {}
local MT = {}

export type ClassType<Tab = {}> =
	typeof(setmetatable({} :: { ClassName: string, _Type: { [string]: string } }, { __index = MT }))
	& Tab

function MT.IsA<Tab>(self: ClassType<Tab>, className: string): boolean
	return self._Type[className] ~= nil
end

function MT.ExtendType<Tab>(self: Tab & ClassType, typeName: string): ClassType -- & Tab
	local newTypeTab = module.new()
	newTypeTab._Type = self._Type
	newTypeTab.ClassName = self.ClassName

	newTypeTab._Type[typeName] = typeName
	newTypeTab.ClassName = typeName

	return newTypeTab
end

function module.new(): ClassType
	return setmetatable({
		_Type = {},
		ClassName = "TypeObject",
	}, { __index = MT })
end

return module
