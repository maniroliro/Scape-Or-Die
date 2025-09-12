local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lib = require(ReplicatedStorage.lib)
local Signal = lib.ModuleUtils.Signal

local module = {}
module.Data = nil
module.NewDataReceived = Signal.new()
module.DataUpdated = Signal.new()

function module.GetData()
    if module.Data then
        return module.Data
    end

    while not module.Data do
        task.wait(0.05)
    end

    return module.Data
end

return module
