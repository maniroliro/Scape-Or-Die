local replicatedStorage = game:GetService("ReplicatedStorage")
local collectionService = game:GetService("CollectionService")

local lib = require(replicatedStorage.lib)
local packet = lib.ModuleUtils.Packet
local trove = lib.ModuleUtils.Trove
local getLegalUID = lib.Utils.GetLegalUID
local t = lib.FunctionUtils.t
local remotes = lib.Remotes

local dirFolder: Folder = replicatedStorage.Directory

local sharedModules = replicatedStorage.Modules.Shared
local instancesManager = require(sharedModules.Managers.InstancesManager)

local module = setmetatable({}, { __index = instancesManager })

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

function module.new(UID: string?): ClassType
	local self = setmetatable({
		UID = UID or getLegalUID(),
		Trove = trove.new(),
		Remote = remotes.UpdateObj,
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

			local value3 = directories[self._Type]:getItemInfo(self.Id)[k]
			if value3 then
				return value3
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
	local directory = directories[self._Type]
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

function module.Materialize<T>(self: T & ClassType, CF: CFrame?)
	local model = workspace:FindFirstAncestor(self.UID)

	if not model then
		for _, part in collectionService:GetTagged(self._Type) do
			if part:GetAttribute("UID") == self.UID then
				model = part
				break
			end
		end
	end

	model = model or require(replicatedStorage.Directory[self._Type .. "s"]):getItemModel(self.Id):Clone()

	if not model then
		return false
	end

	self.Model = model
	self.Model.Name = self._Type .. " _ " .. self.UID

	model:AddTag(self._Type)
	model:SetAttribute("UID", self.UID)

	if not t.CFrame(CF) then
		return self
	end

	self.CFrame = lib.Utils.GetLegalCFrame(CF :: CFrame)
	model:PivotTo(self.CFrame)

	return self
end

-- function module.Destroy<T>(self: T & ClassType)
-- 	local ok
-- 	if self.Trove and (self.Trove :: any).Clean then
-- 		ok = pcall(function()
-- 			(self.Trove :: any):Clean()
-- 		end)
-- 	end

-- 	local m = (self :: any).Model
-- 	if typeof(m) == "Instance" then
-- 		m:Destroy()
-- 		(self :: any).Model = nil
-- 	end

-- 	local da = (self :: any).DetectionArea
-- 	if typeof(da) == "Instance" then
-- 		da:Destroy()
-- 		(self :: any).DetectionArea = nil
-- 	end

-- 		return ok
-- 	end

return module
