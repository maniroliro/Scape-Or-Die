local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local playersService = game:GetService("Players")

local lib = require(replicatedStorage.lib)
local t = lib.FunctionUtils.t
local charUtil = lib.FunctionUtils.Character
local zonePlus = lib.ModuleUtils.ZonePlus

local sharedModules = replicatedStorage.Modules.Shared
local replicableInstance = require(sharedModules.Classes.ReplicableInstance)
local securityCameraSharedClass = require(sharedModules.Classes.SecurityCameraClass)
local inventorySharedUtil = require(sharedModules.Utils.InventoryUtilShared)

local module = setmetatable({}, { __index = securityCameraSharedClass })

export type ClassType =
	typeof(setmetatable(
		{} :: {
			CameraZone: BasePart?,
			PlayersInTheArea: { Player },
			StartWatchingPlayer: lib.Signal<nil, Player>?,
			FinishWatchingPlayer: lib.Signal<nil, Player>?,
			CheckingPlayersInTheArea: RBXScriptConnection?,
			RotationConnection: RBXScriptConnection?,

			AlreadyRotatedToOneSide: number,
			RotationMultiplier: number,
		},
		{ __index = module }
	))
	& securityCameraSharedClass.ClassType

function module.new(id: string | number?): ClassType
	local self = replicableInstance.newLinkedToAClass(module, securityCameraSharedClass) :: ClassType
	self.PlayersInTheArea = {}
	self.AlreadyRotatedToOneSide = 0
	self.RotationMultiplier = 1

	if id then
		self:AttachId(id)
	end
	return self
end

function module.AttachId(self: ClassType, itemId: number)
	-- Chama o método shared do ReplicableInstance primeiro
	securityCameraSharedClass.AttachId(self, itemId)

	print(self)
	-- Lógica específica do servidor
	self.Remote:Fire(self.UID, "AttachId", { itemId })
	return self
end

function module.AttachCameraZone(self: ClassType, area: Part)
	if not t.instanceIsA("Part")(area) then
		return self
	end

	self.CameraZone = zonePlus.new(area)
	return self
end

function module.Materialize(self: ClassType, wall: BasePart)
	local wallUID = wall:GetAttribute("UID")
	if not wallUID then
		return false
	end
	local success = securityCameraSharedClass.Materialize(self, wallUID)
	if not success then
		return false
	end

	self.Model:PivotTo(self.CFrame)
	self.Model.Parent = self.AttachedToWall.Parent

	local subPart = self.Model:FindFirstChild("NegativePart")
	if subPart then
		--local newWall = self.AttachedToWall:UnionAsync(subPart)

		print(self.AttachedToWall)
		print(subPart)
		local newPart: Part = self.AttachedToWall:SubtractAsync({ subPart })
		subPart:Destroy()
		newPart.Name = self.AttachedToWall.Name
		newPart.CFrame = self.AttachedToWall.CFrame
		newPart.Parent = self.AttachedToWall.Parent
		self.AttachedToWall:Destroy()
		self.AttachedToWall = newPart
		-- TODO: NEXT
		-- SUBTRACT
		-- THE CAM SUB PART
		-- FROM THE WALL PART
		-- MAKE SUB PART EQUAL TO NORMAL PART
	end

	self.Remote:Fire(self.UID, "Materialize", { wallUID })
	return self
end

local part
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
	part.Color = Color3.new(1, 0, 0)
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

			local camEye = self.CameraModel:FindFirstChild("Eye")
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
			print("------------------------")
			print("angle: " .. angle)
			print("distance: " .. distance)
			if angle <= self.FOV / 2 and distance < self.ViewMaxDistance then
				createDebugPart(camEye.Position, char.Position)
				print("Player in sight", player)
				local inv = inventorySharedUtil.getPlayerInventory(player)
				if inventorySharedUtil.isThereAnIlegalItemOnInventory(inv) then
					part.Color = Color3.new(0, 1, 0)
					print("player triggered")
					self:AlertPolices(player)
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
	print()
	local sucess = securityCameraSharedClass.Active(self, active)
	print(sucess)
	if not sucess then
		return self
	end
	print(self.isActivated)
	if self.isActivated then
		print(self.CameraZone)
		if self.CameraZone then
			print(self.CameraZone)
			self.StartWatchingPlayer = self.Trove:Connect(self.CameraZone.playerEntered, function(plr)
				print(plr)
				self:StartWatching(plr)
			end)

			self.FinishWatchingPlayer = self.Trove:Connect(self.CameraZone.playerExited, function(plr)
				print(plr)
				self:StopWatchingPlayer(plr)
			end)
		else
			print(playersService:GetPlayers())

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

		local db = 0
		print("sssss", self.RotationDelay, self.RotationAngle)
		self.RotationConnection = self.Trove:Connect(runService.Heartbeat, function(dt)
			db = db + dt
			if db < self.RotationDelay then
				return
			end
			db = 0
			if self.CameraModel and self.AttachedToWall then
				self.AlreadyRotatedToOneSide = self.AlreadyRotatedToOneSide + 1
				self.CameraModel:PivotTo(
					self.CameraModel:GetPivot()
						* CFrame.Angles(0, math.rad(self.RotationAngle) * self.RotationMultiplier, 0)
				)
				if (self.AlreadyRotatedToOneSide :: number) >= (self.RotationToEachSide :: number) then
					self.RotationMultiplier = self.RotationMultiplier * -1
					self.AlreadyRotatedToOneSide = -2
				end
			end
		end)
	else
		print()
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
	local newItem = lib.Remotes.instanceCreated.SecurityCamera

	if client then
		newItem:FireClient(client, self.UID)

		self.Remote:FireClient(client, self.UID, "AttachId", { self.Id })
		self.Remote:FireClient(
			client,
			self.UID,
			"Materialize",
			{ self.AttachedToWall and self.AttachedToWall:GetAttribute("UID") }
		)
		self.Remote:FireClient(client, self.UID, "Active", { self.isActivated })
	else
		newItem:Fire(self.UID)

		self.Remote:Fire(self.UID, "AttachId", { self.Id })
		self.Remote:Fire(self.UID, "Materialize", { self.AttachedToWall and self.AttachedToWall:GetAttribute("UID") })
		self.Remote:Fire(self.UID, "Active", { self.isActivated })
	end

	return self
end

return module
