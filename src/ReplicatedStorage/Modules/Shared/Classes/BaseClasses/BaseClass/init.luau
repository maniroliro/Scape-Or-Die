local module = {}
local MT = {}

export type ClassType<T = { any }> = typeof(setmetatable({} :: {}, { __index = MT })) & T

module.AddInheritance2 = function<A, B>(
	selfTab: A,
	B: B,
	specialFunc: (({ [any]: any }, any) -> any)?
): ClassType<A & B> --ClassType<B>
	local self
	self = setmetatable({}, {
		__index = function(tab, k)
			local value = (B :: any)[k] or (selfTab :: any)[k] -------------------is that necessary? (selfTab :: any)[k] ----------------------------------------------------------------------------
			if value then
				return value
			end

			if specialFunc then
				local value2 = specialFunc(tab, k)
				if value2 then
					return value2
				end
			end
			return nil
		end,
	})

	return self
end

module.AddInheritance = function<A, B>(selfTab: A, B: B, specialFunc: (({ [any]: any }, any) -> any)?): ClassType<A & B>
	local oldMT = getmetatable(selfTab :: any)
	-- local oldIndex = oldMT.__index
	-- local oldIndexType = type(oldIndex)
	--print(oldMT)
	--print(oldMT.__index)
	selfTab = setmetatable(selfTab :: any, {
		__index = function(tab, k)
			local value = (B :: any)[k] ~= nil and (B :: any)[k]
				or (
					oldMT
					and (
						(type(oldMT.__index) == "function" and oldMT.__index(tab, k))
						or (type(oldMT.__index) == "table" and oldMT.__index[k])
					)
				)
			if value ~= nil then
				return value
			end

			if specialFunc then
				local value2 = specialFunc(tab, k)
				if value2 ~= nil then
					return value2
				end
			end
			return nil
		end,
	})

	return selfTab :: ClassType<A & B>
end

-- module.AddInheritance = function<A, B>(
-- 	selfTab: A,
-- 	B: B,
-- 	specialFunc: (({ [any]: any }, any) -> any)?
-- ): A & B --B & typeof(setmetatable({} :: A, { __index = {} })) & typeof(setmetatable({} :: B, { __index = {} }))
-- 	local self = setmetatable({}, { __index = B })
-- 	if type(specialFunc) == "function" then
-- 		self = setmetatable({}, {
-- 			__index = function(tab, k)
-- 				local value = (B :: any)[k] or specialFunc(tab, k)
-- 				if value then
-- 					return value
-- 				end

-- 				return nil
-- 			end,
-- 		})
-- 	end

-- 	return self
-- end

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

function module.new<A>(a: A?): ClassType<A>
	local self = setmetatable((a or {}) :: { any }, { __index = MT })
	return self
end

function MT.newFromThis<T, A>(self: ClassType<T>, a: A?, specialFunc: (({ [any]: any }, any) -> any)?): ClassType<A & T>
	--local new = module.new(a):AddInheritance(self, specialFunc)
	local new = module.AddInheritance(a or {}, self, specialFunc)
	--local new = setmetatable((a or {}) :: { any }, { __index = self })
	return new
end

MT.AddInheritance = module.AddInheritance

return module
