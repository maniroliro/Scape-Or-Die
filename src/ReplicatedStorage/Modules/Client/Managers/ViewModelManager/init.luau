local camera = workspace.CurrentCamera
local localPlayer = game:GetService("Players").LocalPlayer

local module = {}
module.ViewModel = nil
module.Attachment = nil
module.ItemAttached = nil
module._lastItemParent = localPlayer

function module.SetViewModel(model: Model)
	module.ViewModel = model
	module.Attachment = model:FindFirstChild("Attachment", true)
	--module.ViewModel:PivotTo(camera.CFrame)

	if module.ItemAttached then
		module._lastItemParent = localPlayer
		module.UnattachItem()
	end

	module.ViewModel.Parent = workspace
end

function module.AttachItem(item: Model)
	if not module.ViewModel or not module.Attachment then
		return false
	end
	if typeof(item) == "Instance" and item:IsA("Model") then
		return false
	end
	if module.ItemAttached then
		module.UnattachItem()
	end
	module._lastItemParent = item.Parent
	module.ItemAttached = item
	item:PivotTo(module.Attachment.CFrame)

	item.Parent = camera
	return true
end

function module.UnattachItem()
	if not module.ItemAttached then
		return false
	end

	module.ItemAttached.Parent = module._lastItemParent or localPlayer
	module.ItemAttached = nil

	return true
end

return module
