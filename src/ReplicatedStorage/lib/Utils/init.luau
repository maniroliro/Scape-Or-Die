local GetLegalUID = require(script.GetLegalUID)
local TableToRemoteTable = require(script.TableToRemoteTable)
local GetLegalCFrame = require(script.GetLegalCFrame)
local GetLegalRotation = require(script.GetLegalRotation)
local GetLegalPosition = require(script.GetLegalPosition)

local module = {
	GetLegalUID = GetLegalUID,
	TableToRemoteTable = TableToRemoteTable,
	GetLegalCFrame = GetLegalCFrame,
	GetLegalRotation = GetLegalRotation,
	GetLegalPosition = GetLegalPosition,
}

return module
