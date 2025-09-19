function CanUse(itemInfoTab: { [string]: any })
	return true
end

function Use(itemInfoTab: { [string]: any }, ...)
	return true
end

return {
	CanUse = CanUse,
	Use = Use,
}
