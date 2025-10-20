local module = {}
local MT = {}
module.indexMTCallback = function(k, realClassModule, sharedClassModule)
	--print(self, k)
	local value1 = rawget(realClassModule, k)
	if value1 then
		return value1
	end

	local value2 = (sharedClassModule :: any)[k]
	if value2 then
		return value2
	end

	return nil
end

export type ClassType<T = {}> = typeof(setmetatable({} :: {} & T, { __index = MT }))

function module.new(): ClassType
	local self = {}
	return self
end

function MT.addInherance<A, B, C, D, E, F, G>(
	realClassModule: A,
	B: B,
	C: C?,
	D: D?,
	E: E?,
	F: F?,
	G: G?
): ClassType<A & B & C & D & E & F & G>
	local self

	local inheritTable = {
		realClassModule,
		B,
		C,
		D,
		E,
		F,
		G,
	}

	for i = 1, #inheritTable do
		local nextTab = inheritTable[i + 1]
		if not nextTab then
			break
		end
		self = setmetatable(nextTab :: any, {
			__index = function(self, k)
				--print(self, k)
				local value1 = (inheritTable[i] :: any)[k]
				if value1 then
					return value1
				end

				return nil
			end,
		})
	end

	return self
end

return module
