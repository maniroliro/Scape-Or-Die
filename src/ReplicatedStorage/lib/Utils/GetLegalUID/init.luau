return function() : string
	local httpsService = game:GetService('HttpService')
	local uid = httpsService:GenerateGUID(false)
	return string.gsub(uid, '-', '')
end