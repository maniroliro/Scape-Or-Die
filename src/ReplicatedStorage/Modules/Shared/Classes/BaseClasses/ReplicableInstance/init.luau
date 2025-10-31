local replicatedStorage = game:GetService("ReplicatedStorage")
local collectionService = game:GetService("CollectionService")
local runService = game:GetService("RunService")

local lib = require(replicatedStorage.lib)
local packet = lib.ModuleUtils.Packet
local trove = lib.ModuleUtils.Trove
local getLegalUID = lib.Utils.GetLegalUID
local t = lib.FunctionUtils.t
local remotes = lib.Remotes

local dirFolder: Folder = replicatedStorage.Directory

local sharedModules = replicatedStorage.Modules.Shared
local instancesManager = require(sharedModules.Managers.InstancesManager)
local destroyMethodUtil = require(sharedModules.Utils.DestroyObject)

local baseClass = require(sharedModules.Classes.BaseClasses.BaseClass)
local objType = require(sharedModules.Classes.BaseClasses.ObjectType)

---local MT = baseClass.new({}):AddInheritance(objType.new()):ExtendType("ReplicableInstance")

local MT = {}
local MTClass = baseClass.new(MT):AddInheritance(objType.new()) --:AddInheritance({a = 2}):AddInheritance({o = true})  --:AddInheritance({a = 2}) --:AddInheritance(objType.new())
MTClass:ExtendType("ReplicableInstance")

local module = {}
--local moduleClass = baseClass.new(module):AddInheritance(MTClass)
local moduleClass = MTClass:newFromThis(module) --:AddInheritance(MTClass)
local directories = {}

for _, dirType in dirFolder:GetChildren() do
	if not dirType:IsA("ModuleScript") then
		continue
	end
	local sub1 = dirType.Name:sub(#dirType.Name, #dirType.Name)
	local name = sub1 == "s" and dirType.Name:sub(1, #dirType.Name - 1) or dirType.Name:sub(1, #dirType.Name)
	directories[name] = require(dirType)
end

export type MaterializeInfo = {
	CFrame: CFrame,
	Model: Model | BasePart,
	Suffix: string,
}

function module.NormalizeToMaterializeInfo(...): MaterializeInfo
	local info = {} :: any
	for _, v in table.pack(...) do
		if type(v) == "string" then
			info["Suffix"] = v
		elseif typeof(v) == "Instance" and v:IsA("Model") then
			info["Model"] = v
		elseif typeof(v) == "CFrame" then
			info["CFrame"] = v
		end
	end

	return info
end

export type genericObjType = instancesManager.genericObjType

export type ClassType2 =
	typeof(setmetatable(
		{} :: {
			Remote: typeof(packet("")),
			Trove: typeof(trove.new()),
			Replicate: typeof(instancesManager.Replicate),
		},
		{ __index = MTClass }
	))
	& genericObjType
	--& baseClass.ClassType<typeof(MT)>
	& typeof(MTClass)

export type ClassType<T = {}> =
	baseClass.ClassType<typeof({} :: {
		Remote: typeof(packet("")),
		Trove: typeof(trove.new()),
		Replicate: typeof(instancesManager.Replicate),
	}) & genericObjType & T>
	& typeof(MTClass)

function module.new<T>(UID: string?): ClassType<T>
	local obj = instancesManager.getObj(UID :: string)
	if obj then
		return obj
	end
	local self = baseClass
		.new({
			UID = UID or getLegalUID(),
			Trove = trove.new(),
			Remote = remotes.UpdateObj,
			Replicate = instancesManager.Replicate,
			Destroying = false,
		})
		:AddInheritance(MTClass, function(tab, k)
			-- warn(k)
			local typeName = tab.ClassName
			-- print(tab._Type)
			-- print(typeName)
			if typeName then
				local directory = directories[typeName]
				-- print(directory)
				if directory then
					-- warn(k)
					-- print(tab._Type)
					-- print(typeName)
					-- print(directory)
					local value3 = directory:getItemInfo(tab.Id)[k]
					warn(value3)
					if value3 then
						return value3
					end
				end
			end
			return nil
		end)

	instancesManager.addObj(self)
	return self --:: ClassType
end

-- function module.newLinkedToAClass<A, B, C, D, E, F, G>(
-- 	realClassModule: A,
-- 	B: B,
-- 	C: C?,
-- 	D: D?,
-- 	E: E?,
-- 	F: F?,
-- 	G: G?
-- ): ClassType<A & B & C & D & E & F & G>
-- 	local self

-- 	local inheritTable = {
-- 		realClassModule,
-- 		B,
-- 		C,
-- 		D,
-- 		E,
-- 		F,
-- 		G,
-- 	}

-- 	for i = 1, #inheritTable do
-- 		local nextTab = inheritTable[i + 1]
-- 		if not nextTab then
-- 			break
-- 		end
-- 		self = setmetatable(nextTab :: any, {
-- 			__index = function(self, k)
-- 				--print(self, k)
-- 				local value1 = (inheritTable[i] :: any)[k]
-- 				if value1 then
-- 					return value1
-- 				end

-- 				warn(k)
-- 				local typeName = self.ClassName
-- 				print(typeName)
-- 				if typeName then
-- 					local directory = directories[typeName]
-- 					print(directory)
-- 					if directory then
-- 						local value3 = directory:getItemInfo(self.Id)[k]
-- 						warn(value3)
-- 						if value3 then
-- 							return value3
-- 						end
-- 					end
-- 				end

-- 				return nil
-- 			end,
-- 		})
-- 	end

-- 	return self
-- end

function MT.Replicate<T>(self: T & ClassType<T>, replicate: boolean?): T & ClassType<T>
	self:Replicate(replicate)

	return self
end

function MT.AttachId<T>(self: ClassType<T>, id: number): ClassType<T>
	local typeName = self.ClassName
	if not typeName then
		return self
	end
	local directory = directories[typeName]
	local info = directory:getItemInfo(id)

	-- for k, v in info do
	-- 	(self :: any)[k] = v
	-- end
	--print(info)
	if info then
		self.Id = id
	end
	return self
end

function MT.Materialize<T>(self: T & ClassType<T>, info: MaterializeInfo, ...): ClassType<T> | boolean
	if type(info) ~= "table" then
		info = module.NormalizeToMaterializeInfo(info, ...)
	end
	local typeName = self.ClassName
	if not typeName then
		return self
	end

	local cframe = info.CFrame
	local modelArg = info.Model
	local suffix = info.Suffix

	local id = self.Id

	local suffixStr = suffix and " _ " .. suffix or ""
	local idStr = id and " _ " .. tostring(id) or ""

	local name = typeName .. idStr .. " _ " .. self.UID .. suffixStr

	if not self.model then
		local model = modelArg and typeof(modelArg) == "Instance" and modelArg:IsA("PVInstance") and modelArg
			or workspace:FindFirstChild(name, true)

		if not model and not suffix then
			for _, part in collectionService:GetTagged(typeName) do
				if part:GetAttribute("UID") == self.UID then
					model = part
					break
				end
			end
		end

		model = model or require(replicatedStorage.Directory[typeName .. "s"]):getItemModel(self.Id):Clone()

		if not model then
			return false
		end

		self.Model = model
		self.Model.Name = name

		self.Model:AddTag(typeName)
		self.Model:SetAttribute("UID", self.UID)
	end
	if not t.CFrame(cframe) then
		return self
	end

	self.CFrame = lib.Utils.GetLegalCFrame(cframe :: CFrame)
	self.Model:PivotTo(self.CFrame)

	return self
end

function MT.Destroy<T>(self: T & ClassType<T>)
	print("1destroying", self.UID)
	if self.Destroying then
		return
	end
	print("2destroying", self.UID)
	self.Destroying = true
	if self.Remote and runService:IsServer() then
		self.Remote:Fire(self.UID, "Destroy", {})
	end
	instancesManager.removeObj(self.UID)
	print("3destroying", self.UID)
	self.Destroy = nil
	destroyMethodUtil(self)
end

function MT.ret<T>(self: ClassType<T>): ClassType<T>
	return self
end

function MT.ret2<T>(self: T): T
	return self
end

-- -- local a = module.new("asd")

-- -- moduleClass.new().ret({a = 2}).

-- local a = {} :: typeof(moduleClass)

-- local c = a.new('21'):AttachId(2)

-- --a:AddInheritance({ a = 0 }):AddInheritance({ ohafg = "" }).new(234234):AddInheritance({ c = 1 }):AttachId(2) -- aqui, new retorna ClassType, oq está correto, e AddInheritance retorna a união das 2 tables, o self e a passada a ele mas AttachId não retorna nada ma sdevia, tendo em vista q está declarado q devia retornar o argumento passado a ele, o self, no caso

-- local b = module.new():AddInheritance({ d = "d" }):AddInheritance({ e = "" }):AddInheritance({ sdfg = 3 }):ret() -- aqui ocorre algo semelhante, AddInheritance retorna a união das tables, mas ret não retorna o self, sendo q explicitamente na função está declarado q ele deve retornar o msm tipo do argumento passado a ele, o self

-- --a.new():AddInheritance({ ad = "" })

return moduleClass
