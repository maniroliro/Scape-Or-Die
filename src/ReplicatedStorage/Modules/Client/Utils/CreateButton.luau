return function(frame: Frame, funcOnClick: () -> ()?)
	if frame and type(frame) == 'userdata' and frame:IsA('Frame') then
		local newButton = game:GetService('ReplicatedStorage').Assets.Displays.ButtonTemplate:Clone()
		newButton.Transparency = frame.Transparency
		newButton.BackgroundColor3 = frame.BackgroundColor3
		
		local uiCorner = frame:FindFirstChildWhichIsA('UICorner')
		if uiCorner then
			uiCorner:Clone().Parent = newButton
		end
		
		--frame.Parent = newButton
		return newButton
	end	
end
