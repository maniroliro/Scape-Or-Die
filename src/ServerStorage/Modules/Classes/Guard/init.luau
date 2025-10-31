local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local playersService = game:GetService("Players")
local serverStorage = game:GetService("ServerStorage")

local sharedModules = replicatedStorage.Modules.Shared

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local charUtil = lib.FunctionUtils.Character
local signal = lib.ModuleUtils.Signal
local getLegalPosition = lib.Utils.GetLegalPosition

local replicableInstance = require(sharedModules.Classes.BaseClasses.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)
local guardSharedClass = require(sharedModules.Classes.GuardClass)
local gameCharacterServerClass = require(serverStorage.Modules.Classes.BaseClasses.GameCharacter)

local forbiddenAi = require(sharedModules.Packages.Forbidden.AI)
local collisionGroupUtils = require(serverStorage.Modules.Utils.CollisionGroup)

-- local module = setmetatable({}, { __index = guardSharedClass }) --:: & replicableInstance.ClassType
local module = {}
local moduleClass = guardSharedClass:newFromThis(module)

export type ClassType = guardSharedClass.ClassType & typeof(moduleClass) & {
	--Character: Model?,
	Head: BasePart?,
	--ChasingPrisoner: Player?,
	LastPositionGoing: Vector3?,
	LastTimeSawPrisoner: number,

	WatchingConnection: RBXScriptConnection?,
	StopChasingThread: thread?,
} -- & gameCharacterServerClass.ClassType

function module.new(id: string | number?): ClassType
	-- local self = replicableInstance.newLinkedToAClass(module, guardSharedClass.new()) :: ClassType
	local self = guardSharedClass.new():AddInheritance(moduleClass)
	self.HealthChanged = self.Trove:Add(signal.new())

	if id then
		self:AttachId(id)
	end
	return self
end

function module.Materialize(self: ClassType, info: replicableInstance.MaterializeInfo)
	local success = guardSharedClass.Materialize(self, info)
	if not success then
		return false
	end

	collisionGroupUtils.setModelCollisionGroup(self.Character, "GuardsCharacters")

	self.Head = self.Character:FindFirstChild("Head")
	self.Character.Parent = workspace
	return self
end

local part
local color = Color3.new(1, 0, 0)
local function createDebugPart(fromVector: Vector3, toVector: Vector3)
	if part then
		part:Destroy()
		part = nil
	end
	local cframe = CFrame.new(fromVector:Lerp(toVector, 0.5), toVector)
	part = Instance.new("Part")
	part.Shape = Enum.PartType.Block
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(0.4, 0.4, (fromVector - toVector).Magnitude)
	part.CFrame = cframe
	part.Transparency = 0.5
	part.Color = color
	part.Parent = workspace

	return part
end

function module.StartWorking(self: ClassType)
	self.LastTimeSawPrisoner = 0

	forbiddenAi.InsertAntiLag(self.Character)
	local config = forbiddenAi.GetConfig(self.Character)
	config.Debugging.Enabled = false
	config.AgentInfo.AgentCanClimb = false
	config.AgentInfo.AgentCanJump = false
	config.AgentInfo.AgentRadius = 1

	config.Visualization.Enabled = true
	config.Visualization.PathColor = Color3.fromRGB(0, 255, 0)

	config.Tracking.Enabled = true

	local dbTime = 0

	local fov = self.FOV
	local range = self.Range
	self.WatchingConnection = self.Trove:Add(runService.Heartbeat:Connect(function(dt)
		dbTime = dbTime + dt
		if dbTime < 0.1 then
			return
		end
		self.LastTimeSawPrisoner = self.LastTimeSawPrisoner + dbTime
		dbTime = 0

		for _, player in playersService:GetPlayers() :: { Player } do
			local rtp = charUtil.getAlivePlayerRootPart(player)
			if not rtp then
				continue
			end

			if self.KnockedDown then
				continue
			end

			local direction = (rtp.Position - self.Character.PrimaryPart.Position)
			local distance = direction.Magnitude

			if distance > range then
				continue
			end

			local directionUnit = (direction).Unit
			local guardLookVectorDirection = self.Head.CFrame.LookVector.Unit * Vector3.new(1, 0, 1)

			local dot = guardLookVectorDirection:Dot(directionUnit)
			local rad = math.acos(dot)
			local angle = math.deg(rad)
			--print("------------------------")
			--print("angle: " .. angle)
			--print("distance: " .. distance)
			if angle <= fov / 2 and distance < range then
				--print("Player in sight", player)

				local isIlegal = true
				-- local inv = inventorySharedUtil.getPlayerInventory(player)
				-- local isIlegal = inventorySharedUtil.isFirstItemIlegal(inv)

				-- CHECK IF PLAYER IS DOING SOMETHING NOT COOL

				--print("isIlegal", isIlegal)
				if isIlegal then
					color = Color3.new(0, 1, 0)

					local params = RaycastParams.new()
					params.FilterType = Enum.RaycastFilterType.Exclude
					params.FilterDescendantsInstances = self.Character and { self.Character } or nil
					local result = workspace:Raycast(self.Head.Position, directionUnit * range, params)
					--print(result and result.Instance)
					--print(result.Instance:IsDescendantOf(rtp.Parent))
					if result and result.Instance:IsDescendantOf(rtp.Parent) then
						--print("player triggered")
						self.LastTimeSawPrisoner = 0
						self.ChasingPrisoner = player
						self.LastPositionGoing = rtp.Position
					end
				end
			end
			color = Color3.new(1, 0, 0)
		end

		if (self.LastTimeSawPrisoner :: number) < 3 and self.ChasingPrisoner then
			local hrp = charUtil.getAlivePlayerRootPart(self.ChasingPrisoner)
			if not hrp then
				self.ChasingPrisoner = nil
				return
			end
			createDebugPart(self.Head.Position, hrp.Position)
			forbiddenAi.SmartPathfind(self.Character, getLegalPosition(hrp.Position))

			if self.StopChasingThread then
				task.cancel(self.StopChasingThread)
				self.StopChasingThread = nil
			end
			self.StopChasingThread = task.delay(3, function()
				self.ChasingPrisoner = nil
			end)
			return
		else
			if (self.Character.PrimaryPart :: Part).AssemblyLinearVelocity.Magnitude < 3 then
				forbiddenAi.SmartPathfind(
					self.Character,
					getLegalPosition(Vector3.new(math.random(0, 50), 0, math.random(0, 50)))
				)
			end
		end
	end))

	return self
end

function module:Destroy() end

return module
