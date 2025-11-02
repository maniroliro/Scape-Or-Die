local objectTypeUtil = require(game.ReplicatedStorage.Modules.Shared.Classes.BaseClasses.ObjectType)
local trove = require(game.ReplicatedStorage.lib.lib.ModuleUtils._Trove)

export type genericObjType = {
	UID: string,
	Destroying: boolean?,
} & { [string]: any } & objectTypeUtil.ClassType

export type InstanceArgsType = string | genericObjType

local module = {}
module.Trove = trove.new()
module.objsCreated = {
	ToReplicate = {} :: { [string]: genericObjType },
	NotToReplicate = {} :: { [string]: genericObjType },
}

function module.Replicate<T>(self: T & genericObjType, replicate: boolean?): T & genericObjType
	local UID = self.UID
	local notToReplicateTab = module.objsCreated.NotToReplicate
	local toReplicateTab = module.objsCreated.ToReplicate

	replicate = replicate == nil and true or replicate

	if replicate and notToReplicateTab[UID] then
		notToReplicateTab[UID] = nil
		toReplicateTab[UID] = self
		self:ReplicateTo()
	else
		toReplicateTab[UID] = nil
		notToReplicateTab[UID] = self
	end

	return self
end

function module.addObj(self: genericObjType, replicate: boolean?)
	module.Trove:Add(self)
	module.Replicate(self, replicate)
end

function module.removeObj(UID: string)
	local obj = module.getObj(UID)
	if not obj then
		return
	end
	module.objsCreated.ToReplicate[UID] = nil
	module.objsCreated.NotToReplicate[UID] = nil

	if not obj.Destroying then
		if (obj :: any).Destroy then
			(obj :: any):Destroy()
		end
	end
	module.Trove:Remove(obj)
end

local function _getObjByUID(UID: string): genericObjType?
	return module.objsCreated.ToReplicate[UID] or module.objsCreated.NotToReplicate[UID]
end

function module.getObj(instanceOrUID: InstanceArgsType): genericObjType?
	local typeI = type(instanceOrUID)
	if typeI == "table" then
		local uid = (instanceOrUID :: any).UID
		if uid then
			return instanceOrUID :: any
		end
	elseif typeI == "string" then
		return _getObjByUID(instanceOrUID :: any)
	end
	return nil
end

-- local function findInTab(tab: { [any]: any }, info: { [any]: any })
-- 	if type(tab) ~= "table" then
-- 		return nil
-- 	end
-- 	for k, v in info do
-- 		if tab[k] ~= v then
-- 			return nil
-- 		end
-- 	end
-- 	return true
-- end

function module.isInstanceInWhich(uid: InstanceArgsType, callback: (instanceTab: { [any]: any }) -> boolean)
	local instance = module.getObj(uid)
	if not instance then
		return false
	end

	return callback(instance) and instance or false
end

function module.FindFirstInstanceInWhich(callback: (instanceTab: { [any]: any }) -> boolean, replicable: boolean?)
	local tabToFind = (replicable == true and module.objsCreated.ToReplicate)
		or (replicable == false and module.objsCreated.NotToReplicate)
		or nil
	print(tabToFind)
	if tabToFind then
		for _, tab in tabToFind do
			if callback(tab) then
				return tab
			end
		end
	else
		print("")
		for _, tab in module.objsCreated.ToReplicate do
			print("bbbbbbbbbbbbbbbbbbb", tab.ControlledBy == game.Players.LocalPlayer and tab)
			if callback(tab) then
				return tab
			end
		end
		print("")
		for _, tab in module.objsCreated.NotToReplicate do
			print("bbbbbbbbbbbbbbbbbbb", tab.ControlledBy == game.Players.LocalPlayer and tab)
			if callback(tab) then
				return tab
			end
		end
		print("")
	end

	return nil
end

return module
