local packet = require(game:GetService("ReplicatedStorage").lib.lib.ModuleUtils._Packet)

local module = {
	PlayerLoaded = packet("PlayerLoaded"),
	PlayerDataUpdated = packet("PlayerDataUpdated", { { Key = packet.String, Value = packet.Any } }),

	-- instanceCreated = {
	-- 	Chest = packet("Chest", packet.String), --:Response(packet.Boolean8),
	-- 	Item = packet("Item", packet.String), --:Response(packet.Boolean8),
	-- 	SecurityCamera = packet("SecurityCamera", packet.String), --:Response(packet.Boolean8),
	-- 	Scanner = packet("Scanner", packet.String), --:Response(packet.Boolean8),
	-- 	Wall = packet("Wall", packet.String), --:Response(packet.Boolean8),
	-- },
	instanceCreated = packet("instanceCreated", packet.String, packet.String), --instanceType, UID
	UpdateObj = packet("UpdateObj", packet.String, packet.String, { packet.Any }),

	--AddItemToInventory = packet("AddItemToInventory", packet.String),
	--EquipItem = packet("EquipItem", packet.String),

	ChangeItemPositionOnInventory = packet("ChangeItemPositionOnInventory", packet.NumberS8, packet.NumberS8),

	CraftItem = packet("CraftItem", packet.NumberS8, packet.NumberS8), --:Response(packet.Boolean8),
}

--for _, remote in module.instanceCreated do
--	remote.ResponseTimeout = 2
--	remote.ResponseTimeoutValue = false
--end

return module
