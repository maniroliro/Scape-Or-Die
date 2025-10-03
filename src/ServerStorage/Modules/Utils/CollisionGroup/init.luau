local physicsService = game:GetService("PhysicsService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t

local module = {}

function module.CollisionGroupSetCollidable(group1: string, group2: string, canCollide: boolean)
	if t.string(group1) and t.string(group2) and t.boolean(canCollide) then
		if not physicsService:IsCollisionGroupRegistered(group1) then
			physicsService:RegisterCollisionGroup(group1)
		end
		if not physicsService:IsCollisionGroupRegistered(group2) then
			physicsService:RegisterCollisionGroup(group2)
		end
		physicsService:CollisionGroupSetCollidable(group1, group2, canCollide)
	end
end

function module.SetCollisionGroup(part: BasePart, groupName: string)
	if not t.instanceIsA("BasePart")(part) then
		return
	end

	if physicsService:IsCollisionGroupRegistered(groupName) then
		part.CollisionGroup = groupName
	end
end

function module.setModelCollisionGroup(model: Model, groupName: string)
	if not t.Instance(model) then
		return
	end

	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			module.SetCollisionGroup(part, groupName)
		end
	end
end

return module
