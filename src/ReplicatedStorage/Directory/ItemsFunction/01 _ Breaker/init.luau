local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local lib = require(replicatedStorage:WaitForChild("lib"))
local t = lib.FunctionUtils.t
local charUtil = lib.FunctionUtils.Character
local instancesManager = require(replicatedStorage.Modules.Shared.Managers.InstancesManager)

local MAX_DISTANCE = 6
local MIN_FORWARD_DOT = 0.25

local function getModelPosition(model: PVInstance)
	if model:IsA("BasePart") then
		return model.Position
	elseif model:IsA("Model") then
		local primary = model.PrimaryPart
		if primary then
			return primary.Position
		end
		local cf = model:GetPivot()
		return cf.Position
	end

	local cf = model:GetPivot()
	return cf.Position
end

local function getJailComponentFromInstance(inst: Instance)
	local current = inst
	while current do
		if current:IsA("PVInstance") then
			local uid = current:GetAttribute("UID")
			if uid then
				local obj = instancesManager.getObj(uid)
				if instancesManager.objectIs(obj, "JailComponent") then
					return obj
				end
			end
		end
		current = current.Parent
	end

	return nil
end

local function isInFront(rootPart: BasePart, targetPos: Vector3)
	local toTarget = targetPos - rootPart.Position
	if toTarget.Magnitude == 0 then
		return true
	end

	return toTarget.Unit:Dot(rootPart.CFrame.LookVector) >= MIN_FORWARD_DOT
end

local function getTargetHit(player: Player, head: BasePart)
	-- if runService:IsClient() then
	-- 	local mouse = player:GetMouse()
	-- 	if mouse then
	-- 		return mouse.Target, mouse.Hit and mouse.Hit.Position
	-- 	end
	-- else
	local character = player.Character
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = character and { character } or nil
	local result = workspace:Raycast(head.Position, head.CFrame.LookVector * MAX_DISTANCE, params)
	if result then
		return result.Instance, result.Position
	end
	-- end
	return nil
end

local function CanUse(item)
	if not item then
		return false
	end

	local player = item.InstantiatedTo
	if not t.Player(player) then
		return false
	end

	local rootPart = charUtil.getAlivePlayerRootPart(player)
	if not rootPart then
		return false
	end

	local head = player.Character and player.Character:FindFirstChild("Head")
	if not head then
		return false
	end

	local targetPart, hitPosition = getTargetHit(player, head)
	if not targetPart then
		return false
	end

	local jailComponent = getJailComponentFromInstance(targetPart)
	if not jailComponent or not jailComponent.Model or jailComponent.Health <= 0 then
		return false
	end

	if not targetPart:IsDescendantOf(jailComponent.Model) and jailComponent.Model ~= targetPart then
		return false
	end

	local componentPos = getModelPosition(jailComponent.Model)
	local referencePosition = targetPart.Position or componentPos
	print((targetPart.Position - rootPart.Position).Magnitude, (componentPos - rootPart.Position).Magnitude)
	if referencePosition and (referencePosition - rootPart.Position).Magnitude > MAX_DISTANCE then
		return false
	end

	if not isInFront(rootPart, componentPos) then
		return false
	end

	return jailComponent
end

local function UseItem(item)
	local jailComponent = CanUse(item)
	if not jailComponent then
		return false
	end

	jailComponent:DestroyModel()
	--decrease
	return true
end

return {
	CanUse = CanUse,
	UseItem = UseItem,
}
