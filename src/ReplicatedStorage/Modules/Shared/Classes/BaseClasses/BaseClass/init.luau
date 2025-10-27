local module = {}
local MT = {}

export type ClassType<T = { any }> = typeof(setmetatable({} :: {}, { __index = MT })) & T

module.AddInheritance = function<A, B>(selfTab: A, B: B, specialFunc: (({ [any]: any }, any) -> any)?): A & B
	local self = setmetatable({}, {
		__index = function(self, k)
			local value = (B :: any)[k] or (selfTab :: any)[k]
			if value then
				return value
			end

			if specialFunc then
				local value2 = specialFunc(self, k)
				if value2 then
					return value2
				end
			end
			return nil
		end,
	})
	return self
end

-- module.AddInherance = function<A, B>(selfTab: A, B: B, specialFunc: ({ [any]: any }, any) -> any?): A & B
-- 	if not B then
-- 		return selfTab :: A & B
-- 	end
-- 	local self = setmetatable(B :: any, {
-- 		__index = function(self, k)
-- 			--print(self, k)
-- 			local value1 = (selfTab :: any)[k]
-- 			if value1 then
-- 				return value1
-- 			end

-- 			if specialFunc then
-- 				local value3 = specialFunc(self, k)
-- 				if value3 then
-- 					return value3
-- 				end
-- 			end

-- 			return nil
-- 		end,
-- 	})

-- 	return self
-- end

function module.new<A>(a: A?): ClassType & A & typeof({})
	local self = setmetatable((a or {}) :: { any }, { __index = MT })
	return self
end

function MT.newFromThis<T>(self: ClassType<T>): ClassType<T>
	local new = module.new():AddInheritance(self)
	return new
end

MT.AddInheritance = module.AddInheritance

return module
