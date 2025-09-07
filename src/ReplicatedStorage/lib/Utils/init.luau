local GetLegalUID = require(script.GetLegalUID)
local TableToRemoteTable = require(script.TableToRemoteTable)
local GetLegalCFrame = require(script.GetLegalCFrame)

export type ReplicableInstance = ReplicableInstance.ClassType

local module = {
	GetLegalUID = GetLegalUID,
	TableToRemoteTable = TableToRemoteTable,
	GetLegalCFrame = GetLegalCFrame,
}

return module
