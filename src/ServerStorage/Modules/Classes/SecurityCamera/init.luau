local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local playersService = game:GetService("Players")

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local charUtil = lib.FunctionUtils.Character
local simpleZone = lib.ModuleUtils.Zone

local sharedModules = replicatedStorage.Modules.Shared
local replicableInstanceClass = require(sharedModules.Classes.BaseClasses.ReplicableInstanceClass)
local securityCameraSharedClass = require(sharedModules.Classes.SecurityCameraClass)
local inventorySharedUtil = require(sharedModules.Utils.InventoryUtilShared)

-- local module = setmetatable({}, { __index = securityCameraSharedClass })

local module = {}
local moduleClass = securityCameraSharedClass:newFromThis(module)

export type ClassType = securityCameraSharedClass.ClassType & typeof(moduleClass) & {
	CameraZone: lib.Zone,
	PlayersInTheArea: { Player },
	StartWatchingPlayer: lib.Signal<nil, Player>?,
	FinishWatchingPlayer: lib.Signal<nil, Player>?,
	CheckingPlayersInTheArea: RBXScriptConnection?,
	RotationConnection: RBXScriptConnection?,

	Light: SpotLight,
	Eye: Part,

	AlreadyRotatedToOneSide: number,
	RotationMultiplier: number,
}

function module.new(id: string | number?): ClassType
	-- local self = replicableInstanceClass.newLinkedToAClass(module, securityCameraSharedClass.new()) :: ClassType
	local self = securityCameraSharedClass.new():AddInheritance(moduleClass)
	self.PlayersInTheArea = {}
	self.AlreadyRotatedToOneSide = 0
	self.RotationMultiplier = 1

	if id then
		self:AttachId(id)
	end
	return self
end

function module.AttachId(self: ClassType, itemId: number)
	securityCameraSharedClass.AttachId(self, itemId)

	self.Remote:Fire(self.UID, "AttachId", { itemId })
	return self
end

function module.AttachCameraZone(self: ClassType, area: Part)
	if not t.instanceIsA("Part")(area) then
		return self
	end

	self.CameraZone = simpleZone.SimpleZone.fromParts({ area })
	return self
end

function module.Materialize(self: ClassType, info: replicableInstanceClass.MaterializeInfo)
	local wallUID = info.Model:GetAttribute("UID")
	if not wallUID then
		return false
	end
	local success = securityCameraSharedClass.Materialize(self, wallUID)
	if not success then
		return false
	end

	self.Model:PivotTo(self.CFrame)
	self.Model.Parent = self.AttachedToWall.Parent

	self.Eye = self.CameraModel:FindFirstChild("Eye")
	--print(self.Eye)
	self.Light = self.Eye:FindFirstChild("SpotLight") :: SpotLight
	--print(self.Light)

	if self.Light then
		self.Light.Range = self.ViewMaxDistance
		self.Light.Angle = self.FOV
	end

	local subPart = self.Model:FindFirstChild("NegativePart")
	if subPart then
		local newPart: Part = self.AttachedToWall:SubtractAsync({ subPart })
		subPart:Destroy()
		newPart.Name = self.AttachedToWall.Name
		newPart.CFrame = self.AttachedToWall.CFrame
		newPart.Parent = self.AttachedToWall.Parent
		self.AttachedToWall:Destroy()
		self.AttachedToWall = newPart
	end

	self.Remote:Fire(self.UID, "Materialize", { wallUID })
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

function module.StartWatching(self: ClassType, plr: Player?)
	if plr then
		local find = table.find(self.PlayersInTheArea, plr)
		if not find then
			table.insert(self.PlayersInTheArea, plr)
		end
	end
	if self.CheckingPlayersInTheArea then
		return self
	end
	local dbTime = 0

	local fov = self.FOV
	local range = self.ViewMaxDistance
	self.CheckingPlayersInTheArea = self.Trove:Connect(runService.Heartbeat, function(dt)
		dbTime = dbTime + dt
		if dbTime < 0.05 then
			return
		end
		dbTime = 0

		for _, player in self.PlayersInTheArea :: { Player } do
			local char = charUtil.getAlivePlayerRootPart(player)
			if not char then
				continue
			end

			local camEye = self.Eye
			if not camEye then
				return
			end

			local direction = (char.Position - camEye.Position)
			local directionUnit = (direction).Unit
			local distance = direction.Magnitude
			local camEyeDirection = camEye.CFrame.LookVector.Unit -- * distance + camEye.Position).Unit

			local dot = camEyeDirection:Dot(directionUnit)
			local rad = math.acos(dot)
			local angle = math.deg(rad)
			--print("------------------------")
			--print("angle: " .. angle)
			--print("distance: " .. distance)
			if angle <= fov / 2 and distance < range then
				createDebugPart(camEye.Position, char.Position)
				--print("Player in sight", player)
				local inv = inventorySharedUtil.getPlayerInventory(player)
				local isIlegal = inventorySharedUtil.isFirstItemIlegal(inv)
				--print("isIlegal", isIlegal)
				if isIlegal then
					color = Color3.new(0, 1, 0)
					print("player triggered")
					self:AlertPolices(player)
				else
					color = Color3.new(1, 0, 0)
				end
				continue
			end
		end
	end)

	return self
end

function module.FinishWatching(self: ClassType)
	if self.CheckingPlayersInTheArea then
		self.CheckingPlayersInTheArea:Disconnect()
		self.CheckingPlayersInTheArea = nil
	end

	return self
end

function module.AlertPolices(self: ClassType) end

function module.StopWatchingPlayer(self: ClassType, plr: Player)
	local find = table.find(self.PlayersInTheArea, plr)
	if find then
		table.remove(self.PlayersInTheArea, find)
	end

	if #self.PlayersInTheArea == 0 then
		self:FinishWatching()
	end

	return self
end

function module.Active(self: ClassType, active: boolean?)
	local sucess = securityCameraSharedClass.Active(self, active)
	if not sucess then
		return self
	end
	if self.isActivated then
		if self.CameraZone then
			self.StartWatchingPlayer = self.Trove:Add(self.CameraZone:ListenTo("Player", "Entered", function(plr)
				print(plr)
				self:StartWatching(plr)
			end))
			self.FinishWatchingPlayer = self.Trove:Add(self.CameraZone:ListenTo("Player", "Exited", function(plr)
				print(plr)
				self:StopWatchingPlayer(plr)
			end))

			self.CameraZone:BindToHeartbeat()
		else
			for _, plr in playersService:GetPlayers() do
				self:StartWatching(plr)
			end

			self.StartWatchingPlayer = playersService.PlayerAdded:Connect(function(plr)
				print(plr)
				self:StartWatching(plr)
			end)
			self.FinishWatchingPlayer = playersService.PlayerRemoving:Connect(function(plr)
				print(plr)
				self:StopWatchingPlayer(plr)
			end)
		end

		local rotationToEachSide = self.RotationToEachSide or 2
		local rotationAngle = self.RotationAngle or 5
		if rotationToEachSide > 0 and rotationAngle > 0 then
			local db = 0
			local rotationDelay = self.RotationDelay or 0.5
			self.RotationConnection = self.Trove:Connect(runService.Heartbeat, function(dt)
				db = db + dt
				if db < rotationDelay then
					return
				end
				db = 0
				if self.CameraModel and self.AttachedToWall then
					self.AlreadyRotatedToOneSide = self.AlreadyRotatedToOneSide + 1
					self.CameraModel:PivotTo(
						self.CameraModel:GetPivot()
							* CFrame.Angles(0, math.rad(rotationAngle) * self.RotationMultiplier, 0)
					)
					if (self.AlreadyRotatedToOneSide :: number) >= (rotationToEachSide :: number) then
						self.RotationMultiplier = self.RotationMultiplier * -1
						self.AlreadyRotatedToOneSide = -2
					end
				end
			end)
		end
	else
		if self.StartWatchingPlayer then
			self.StartWatchingPlayer:Disconnect()
			self.StartWatchingPlayer = nil
		end
		if self.FinishWatchingPlayer then
			self.FinishWatchingPlayer:Disconnect()
			self.FinishWatchingPlayer = nil
		end
		if self.RotationConnection then
			self.RotationConnection:Disconnect()
			self.RotationConnection = nil
		end
	end

	return self
end

function module.ReplicateTo(self: ClassType, client: Player?)
	local newItem = lib.Remotes.instanceCreated

	if client then
		newItem:FireClient(client, "SecurityCamera", self.UID)

		self.Remote:FireClient(client, self.UID, "AttachId", { self.Id })
		self.Remote:FireClient(
			client,
			self.UID,
			"Materialize",
			{ self.AttachedToWall and self.AttachedToWall:GetAttribute("UID") }
		)
		self.Remote:FireClient(client, self.UID, "Active", { self.isActivated })
	else
		newItem:Fire("SecurityCamera", self.UID)

		self.Remote:Fire(self.UID, "AttachId", { self.Id })
		self.Remote:Fire(self.UID, "Materialize", { self.AttachedToWall and self.AttachedToWall:GetAttribute("UID") })
		self.Remote:Fire(self.UID, "Active", { self.isActivated })
	end

	return self
end

return moduleClass
