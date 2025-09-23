function CanUse(itemInfoTab: { [string]: any })
	return true
end

function Use(player, item, toBreake)
	if not item or not toBreake then
		return
	end

	return true
end

return {
	CanUse = CanUse,
	Use = Use,
}
