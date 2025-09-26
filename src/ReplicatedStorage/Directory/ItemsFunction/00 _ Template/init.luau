function CanUse(...): boolean
	return true
end

function UseItem(...): boolean
	return true
end

return {
	CanUse = CanUse,
	UseItem = UseItem,
}
