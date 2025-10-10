function Destroy(any: any)
	local anyType = typeof(any)

	if anyType == "table" then
		setmetatable(any, nil)
		for k, v in any do
			if type(v) == "table" then
				continue
			end
			Destroy(v)
			any[k] = nil
		end
		--end
	elseif anyType == "Instance" then
		if any:IsA("Player") then
			return any
		end
		any:Destroy()
	elseif anyType == "RBXScriptConnection" then
		any:Disconnect()
	elseif anyType == "thread" then
		task.cancel(any)
	end

	return any
end

return Destroy
