local replicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService('Players')
local runService = game:GetService('RunService')

local lib = require(replicatedStorage:WaitForChild('lib'))
local clientModules = replicatedStorage.Modules.Client
local sharedModules = replicatedStorage.Modules.Shared

local replicableInstance = require(sharedModules.Classes.ReplicableInstance)
local instancesManager = require(sharedModules.Managers.InstancesManager)

local spring = lib.ModuleUtils.Spring
local charUtils = lib.FunctionUtils.Character

local chestDirectory = require(replicatedStorage.Directory.Chests)
local chestSharedClass = require(sharedModules.Classes.ChestClasse)

local itemsReplica = require(clientModules.Replicas.ItemReplica)

local localplayer = PlayersService.LocalPlayer

local module = setmetatable({}, {__index = chestSharedClass})

export type ClassType = typeof(setmetatable(
	{}:: {
		Model: typeof(chestDirectory.directoryFolder["00 | Template"].Model),
		Display: typeof(chestDirectory.directoryFolder["00 | Template"].Display),
		DrawerSpring: typeof(spring.new()),
		DrawerPivotPosition: Vector3,
		ProximityPrompt: ProximityPrompt,
	},
	{__index = module}
)) & chestSharedClass.ClassType

function module.new(UID: string)
	local self: ClassType = replicableInstance.newLinkedToAClass(module, chestSharedClass) :: ClassType
	self._Type = 'Chest'
	self.ItemsInside = {
		DeskContents = {},
		HiddenContents = {}
	}
	
	return self
end

function module.AttachChest(self: ClassType, chestId: number | string)
	--SHARED
end

function module.Materialize(self: ClassType, CF: CFrame)
	self.ProximityPrompt = self.Model.Chest.ProximityPrompt
	
	self.Model:PivotTo(self.CFrame)
	self.Model.Parent = workspace
	self.DrawerPivotPosition = self.Model.Drawer:GetPivot().Position
	
	self.DrawerSpring = spring.new(0)
	self.DrawerSpring.Speed = 15

	self.ProximityPrompt.MaxActivationDistance = self.MaxDistanceToInteract
	self.ProximityPrompt.HoldDuration = self.OpenTime
	
	self.Trove:Add(self.ProximityPrompt.PromptButtonHoldBegan:Connect(function()
		self.Remote:Fire(self.UID, 'playerBeganHoldingProximityPrompt', {})
	end))
	self.Trove:Add(self.ProximityPrompt.PromptButtonHoldEnded:Connect(function() 
		self.Remote:Fire(self.UID, 'playerEndedHoldingProximityPrompt', {})
	end))
	self.Trove:Add(self.ProximityPrompt.Triggered:Connect(function() 
		self.Display.Visible = true
		self.ProximityPrompt.Enabled = false
		
		local con
		con = runService.Heartbeat:Connect(function()
			local plrRootPart = charUtils.getAlivePlayerRootPart(localplayer)
			if not plrRootPart or (plrRootPart.Position - self.CFrame.Position).Magnitude >= self.MaxDistanceToInteract then
				self.Display.Visible = false
				self.ProximityPrompt.Enabled = true
				con:Disconnect()
				con = nil
				return
			end
		end)
		self.Trove:Add(con)
	end))
	


	self.Trove:Add(runService.RenderStepped:Connect(function()
		local hrp = localplayer.Character.PrimaryPart
		local sprPos = self.DrawerSpring.Position
		
		if not hrp then return self end
		if (hrp.Position - self.Model.PrimaryPart.Position).Magnitude <= self.MaxDistanceToInteract then
			self.DrawerSpring.Damping = 0.4
			self.DrawerSpring.Target = 40
			if self.DrawerSpring:IsAtRest() then
				self.DrawerSpring:Reset(40)
				return
			end
			self.Model.Drawer:PivotTo(CFrame.new(self.DrawerPivotPosition) * CFrame.Angles(0,0,math.rad(-sprPos)))
			
			for i, a : Part in self.Model:GetChildren() do
				pcall(function()
					a.Color = Color3.fromRGB(50 + sprPos * 3, 50 + sprPos * 3, 50 + sprPos * 3)
				end)
			end
		else
			self.DrawerSpring.Damping = 0.75
			self.DrawerSpring.Target = 0
			if self.DrawerSpring:IsAtRest() then
				self.DrawerSpring:Reset(0)
				return
			end
			self.Model.Drawer:PivotTo(CFrame.new(self.DrawerPivotPosition) * CFrame.Angles(0,0,math.rad(-sprPos)))
			
			for i, a : Part in self.Model:GetChildren() do
				pcall(function()
					a.Color = Color3.fromRGB(50 + sprPos * 3, 50 + sprPos * 3, 50 + sprPos * 3)
				end)
			end
		end
	end))
	
	self.Display = chestDirectory:getItemDisplay(self.Id):Clone()
	self.Display.Name = self.UID
	self.Display.Visible = false
	self.Display.Parent = localplayer.PlayerGui.Chests
	
	return self
end

function module.AddItem(self: ClassType, itemUID: string, contentName: string?)
	-- SHARED
	
	return self
end

function module.RemoveItem(self: ClassType)
	-- SHARED
	
	return self
end

function module.UpdateItemsInside(self: ClassType, itemsUIDTab: {[string]: {string}})
	for contentName, contentTab in itemsUIDTab do
		self.ItemsInside[contentName] = {}
		for i, uid in contentTab do
			local item = (instancesManager.getObj(uid) or itemsReplica.new(uid)) :: itemsReplica.ClassType
			self:AddItem(uid, contentName)
		end
	end
	
	return self
end

function module.SetOwner(self: ClassType, plr: Player)
	--SHARED

	return self
end


return module
