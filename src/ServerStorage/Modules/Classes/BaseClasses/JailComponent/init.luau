local replicatedStorage = game:GetService("ReplicatedStorage")

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local signal = lib.ModuleUtils.Signal
local zone = lib.ModuleUtils.Zone

local sharedModules = replicatedStorage.Modules.Shared
local jailComponentClass = require(sharedModules.Classes.BaseClasses.JailComponentClass)

local module = {}
local moduleClass = jailComponentClass:newFromThis(module)

export type ClassType = jailComponentClass.ClassType & typeof(moduleClass) & {}

function module.new(id: number?): ClassType
	-- local self = replicableInstanceClass.newLinkedToAClass(module, replicableInstanceClass.new(UID)) :: ClassType
	local self = jailComponentClass.new()

	if id then
		self:AttachId(id)
	end
	return self
end

return moduleClass
