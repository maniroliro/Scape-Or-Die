local camera = workspace.CurrentCamera
local localPlayer = game:GetService("Players").LocalPlayer

local module = {}
module.ViewModel = nil
module.Attachment = nil
module.ItemAttached = nil

function module.SetViewModel(model: Model)
	module.ViewModel = model
	module.Attachment = model:FindFirstChild("Attachment")
	--module.ViewModel:PivotTo(camera.CFrame)

	if module.ItemAttached then
		module.UnattachItem()
	end

	module.ViewModel.Parent = workspace
end

function module.AttachItem(item: Model)
	if not module.ViewModel or not module.Attachment then
		return false
	end
	print()
	if not (typeof(item) == "Instance" and item:IsA("Model")) then
		return false
	end
	print()
	if module.ItemAttached then
		module.UnattachItem()
	end
	print()
	module.ItemAttached = item
	item:PivotTo(module.Attachment.CFrame)

	print(item.Parent)
	item.Parent = module.ViewModel
	print(item.Parent)
	return true
end

function module.UnattachItem(item: Model?)
	print(item)
	print("unattach")
	print(module.ItemAttached)
	if not module.ItemAttached then
		return false
	end
	if item and item ~= module.ItemAttached then
		return false
	end

	module.ItemAttached.Parent = nil
	module.ItemAttached = nil

	return true
end

return module
