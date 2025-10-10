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

local module = setmetatable({}, { __index = instancesManager })
module._Type = instancesManager.buildTypeMap("ReplicableInstance")

local function getPrimaryTypeName(typeDescriptor): string?
	return instancesManager.getPrimaryType(typeDescriptor)
end

local directories = {}

for _, dirType in dirFolder:GetChildren() do
	if not dirType:IsA("ModuleScript") then
		continue
	end
	local sub1 = dirType.Name:sub(#dirType.Name, #dirType.Name)
	local name = sub1 == "s" and dirType.Name:sub(1, #dirType.Name - 1) or dirType.Name:sub(1, #dirType.Name)
	directories[name] = require(dirType)
end

export type genericObjType = instancesManager.genericObjType

export type ClassType =
	typeof(setmetatable(
		{} :: {
			Remote: typeof(packet("")),
			Trove: typeof(trove.new()),
		},
		{ __index = module }
	))
	& genericObjType

function module.extendType(typeName: string, baseMap: instancesManager.TypeMap?): instancesManager.TypeMap
	return instancesManager.buildTypeMap(typeName, baseMap or module._Type)
end

function module.HasType(self: ClassType, query: string): boolean
	return instancesManager.typeIs(self._Type, query)
end

function module.GetPrimaryType(self: ClassType): string?
	return getPrimaryTypeName(self._Type)
end

function module.new(UID: string?): ClassType
	local self = setmetatable({
		UID = UID or getLegalUID(),
		Trove = trove.new(),
		Remote = remotes.UpdateObj,
		Destroying = false,
	}, { __index = module }) :: ClassType

	instancesManager.addObj(self)
	return self
end

function module.newLinkedToAClass<T, T2>(
	realClassModule: { [string]: any },
	sharedClassModule: { [string]: any },
	UID: string?
): ClassType
	local self = setmetatable(sharedClassModule.new(UID), {
		__index = function(self, k)
			--print(self, k)
			local value1 = rawget(realClassModule, k)
			if value1 then
				return value1
			end

			local value2 = sharedClassModule[k]
			if value2 then
				return value2
			end

			--warn(k)
			local typeName = getPrimaryTypeName(self._Type)
			if typeName then
				local directory = directories[typeName]
				if directory then
					local value3 = directory:getItemInfo(self.Id)[k]
					--warn(value3)
					if value3 then
						return value3
					end
				end
			end

			return nil
		end,
	})

	return self
end

-- function module.Replicate<T>(self: T & ClassType, replicate: boolean?)
-- 	self:Replicate(replicate)
-- 	return self
-- end

function module.AttachId<T>(self: T & ClassType, id: number)
	local typeName = getPrimaryTypeName(self._Type)
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

function module.Materialize<T>(self: T & ClassType, CFOrModel: CFrame | Model | BasePart?)
	local typeName = getPrimaryTypeName(self._Type)
	if not typeName then
		return self
	end
	if not self.model then
		local model = CFOrModel and typeof(CFOrModel) == "Instance" and CFOrModel:IsA("PVInstance") and CFOrModel
			or workspace:FindFirstChild(typeName .. " _ " .. self.UID, true)

		if not model then
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
		self.Model.Name = typeName .. " _ " .. self.UID

		self.Model:AddTag(typeName)
		self.Model:SetAttribute("UID", self.UID)
	end
	if not t.CFrame(CFOrModel) then
		return self
	end

	self.CFrame = lib.Utils.GetLegalCFrame(CFOrModel :: CFrame)
	self.Model:PivotTo(self.CFrame)

	return self
end

function module.Destroy<T>(self: T & ClassType & { [string]: any })
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

return module
